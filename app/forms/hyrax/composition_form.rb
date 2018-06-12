# Generated via
#  `rails generate hyrax:work Composition`
module Hyrax
  # Generated form for Composition
  class CompositionForm < Hyrax::Forms::WorkForm
    self.model_class = ::Composition
    self.terms -= [:creator, :keyword, :subject]
    self.terms += [:instruments, :date, :tags,
                   :length, :genre, :software, :medium, :composer]

    self.required_fields = [:title, :instruments]

    # Fields that are automatically drawn on the page below the fold
    def secondary_terms
      terms - primary_terms -
        [:contributor, :rights, :publisher, :date_created, :language,
         :identifier, :base_near, :related_url, :source,
         :files, :visibility_during_embargo, :embargo_release_date,
         :visibility_after_embargo, :visibility_during_lease,
         :lease_expiration_date, :visibility_after_lease, :visibility,
         :thumbnail_id, :representative_id, :ordered_member_ids,
         :member_of_collection_ids, :in_works_ids, :admin_set_id,
         :license, :rights_statement, :rendering_ids]
    end
  end
end
