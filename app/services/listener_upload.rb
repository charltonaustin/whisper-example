class ListenerUpload
  # Positional args each event is broadcast with (see OrderCreator#create),
  # used to check that an uploaded listener's methods can actually be called.
  CALL_ARITIES = {
    "order_created" => 2,
    "order_creation_failed" => 1
  }.freeze

  Result = Struct.new(:class_name, :source, :errors) do
    def valid?
      errors.empty?
    end
  end

  def self.call(source)
    new(source).call
  end

  def initialize(source)
    # Uploaded files are read as ASCII-8BIT (binary) by Rack regardless of
    # actual content; re-tag as UTF-8 so downstream compile/eval/File.write
    # don't choke on multibyte characters.
    @source = source.dup.force_encoding(Encoding::UTF_8)
  end

  def call
    unless @source.valid_encoding?
      return Result.new(nil, @source, [ "File is not valid UTF-8." ])
    end

    begin
      RubyVM::InstructionSequence.compile(@source)
    rescue SyntaxError => e
      return Result.new(nil, @source, [ "File is not valid Ruby: #{e.message}" ])
    end

    sandbox = Module.new
    begin
      sandbox.module_eval(@source, "uploaded_listener.rb")
    rescue StandardError, ScriptError => e
      return Result.new(nil, @source, [ "File could not be loaded: #{e.message}" ])
    end

    classes = sandbox.constants(false).select { |c| sandbox.const_get(c).is_a?(Class) }

    if classes.size != 1
      return Result.new(nil, @source, [ "File must define exactly one class (found #{classes.size})." ])
    end

    class_name = classes.first.to_s
    klass = sandbox.const_get(classes.first)
    errors = []

    known_methods = CALL_ARITIES.keys.select { |method_name| klass.method_defined?(method_name) }

    if known_methods.empty?
      errors << "#{class_name} must define at least one listener method (#{CALL_ARITIES.keys.join(', ')})."
    end

    known_methods.each do |method_name|
      parameters = klass.instance_method(method_name).parameters
      arg_count = CALL_ARITIES[method_name]

      unless compatible_signature?(parameters, arg_count)
        errors << "##{method_name} has a signature incompatible with how it is called (#{arg_count} positional argument(s))."
      end
    end

    Result.new(class_name, @source, errors)
  end

  private

  def compatible_signature?(parameters, arg_count)
    return false if parameters.any? { |type, _| type == :keyreq }

    required = parameters.count { |type, _| type == :req }
    optional = parameters.count { |type, _| type == :opt }
    rest = parameters.any? { |type, _| type == :rest }

    return false if required > arg_count

    rest || (required + optional >= arg_count)
  end
end
