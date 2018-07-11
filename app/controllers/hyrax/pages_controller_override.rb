# Attempting to override from Hyrax Gem 2.1.0:
#   Pages Controller - app/controllers/hyrax/pages_controller.rb

module Hyrax
  module PagesControllerOverride

    private

      # removes :about from permitted_params (I think, ...hope)
      def permitted_params
        params.require(:content_block).permit(:agreement,
                                              :help,
                                              :terms)
      end
  end
end
