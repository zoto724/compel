module Hyrax
  module Renderers
    class MarkdownGeneratedAttributeRenderer < AttributeRenderer

      private

        def li_value(value)
          # Note that html_safe is applied to the value elsewhere in the
          # inherited AttributeRenderer
          value
        end
    end
  end
end
