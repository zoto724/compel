module Compel
  module Metadata
    extend ActiveSupport::Concern

    included do
      property :genre, predicate: ::RDF::Vocab::DC11.type do |index|
        index.as :stored_searchable, :facetable
      end
      property :instruments, predicate: ::RDF::Vocab::DC11.relation do |index|
        index.as :stored_searchable, :facetable
      end
      property :date, predicate: ::RDF::Vocab::DC11.date, multiple: false do |index|
        index.as :stored_searchable, :stored_sortable
      end
      property :tags, predicate: ::RDF::Vocab::DC11.subject do |index|
        index.as :stored_searchable, :facetable
      end
      property :length, predicate: ::RDF::Vocab::DC.extent, multiple: false do |index|
        index.as :stored_searchable
      end
      property :software, predicate: ::RDF::Vocab::DCMIType.Software do |index|
        index.as :stored_searchable
      end
      property :medium, predicate: ::RDF::Vocab::DC.medium do |index|
        index.as :stored_searchable
      end
    end
  end
end
