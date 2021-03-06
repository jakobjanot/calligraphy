# frozen_string_literal: true

module Calligraphy
  # Responsible for creating a duplicate of the source resource identified
  # by the request to the destination resource identified by the URI in
  # the Destination header.
  class Copy < WebDavRequest
    # Executes the WebDAV request for a particular resource.
    def execute
      options = copy_move_options
      copy_options = @resource.copy_options options

      unless copy_options[:can_copy]
        return :precondition_failed if copy_options[:ancestor_exist]
        return :conflict
      end

      return :locked if copy_options[:locked]

      overwritten = @resource.copy options
      overwritten ? :no_content : :created
    end

    private

    def copy_move_options
      {
        depth: @headers['Depth'],
        destination: remove_trailing_slash(destination_header),
        overwrite: @headers['Overwrite'] || true
      }
    end

    def destination_header
      @headers['Destination'].split(@headers['Host']).last
    end

    def remove_trailing_slash(input)
      input.last == '/' ? input[0..-2] : input
    end
  end
end
