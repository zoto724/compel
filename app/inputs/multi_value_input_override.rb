# Attempting to override from Hydra Editor Gem 4.0.2:
#   Multi Value Input - app/inputs/multi_value_input.rb

module MultiValueInputOverride

  private

    # only add a blank entry if the collection is empty
    def collection
      @collection ||= begin
                        val = object.send(attribute_name)
                        col = val.respond_to?(:to_ary) ? val.to_ary : val
                        col.reject { |value| value.to_s.strip.blank? }
                        col + [''] if col.empty?
                        col
                      end
    end
end
