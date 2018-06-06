# Generated via
#  `rails generate hyrax:work Performance`
module Hyrax
  # Generated form for Performance
  class PerformanceForm < Hyrax::Forms::WorkForm
    self.model_class = ::Performance
    self.terms -= [:creator, :keyword, :subject, :license, :rendering_ids]
    self.terms += [:composition_id, :instruments, :date, :tags,
                   :length, :genre, :software, :medium, :location, :performer]

    self.required_fields = [:title, :instruments]

    def primary_terms
      [:title, :composition_id, :instruments]
    end
    
    # Fields that are automatically drawn on the page below the fold
    def secondary_terms
      terms - primary_terms -
        [:contributor, :rights, :publisher, :date_created, :language,
         :identifier, :base_near, :related_url, :source,
         :files, :visibility_during_embargo, :embargo_release_date,
         :visibility_after_embargo, :visibility_during_lease,
         :lease_expiration_date, :visibility_after_lease, :visibility,
         :thumbnail_id, :representative_id, :ordered_member_ids,
         :member_of_collection_ids, :in_works_ids, :admin_set_id]
    end
  end
end
