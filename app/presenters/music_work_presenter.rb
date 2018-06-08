class MusicWorkPresenter < Hyrax::WorkShowPresenter
  delegate :composer, :performer, :instruments, :date, :tags, :length,       
           :genre, :software, :medium, to: :solr_document
end
