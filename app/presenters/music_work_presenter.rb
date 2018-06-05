class MusicWorkPresenter < Hyrax::WorkShowPresenter
  delegate :composer, :performer, :instruments, :date, :tags, :length,       
           :genre, :software, :medium, :location, to: :solr_document
end
