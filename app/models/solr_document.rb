# frozen_string_literal: true
class SolrDocument
  include Blacklight::Solr::Document
  include Blacklight::Gallery::OpenseadragonSolrDocument

  # Adds Hyrax behaviors to the SolrDocument.
  include Hyrax::SolrDocumentBehavior


  # self.unique_key = 'id'

  # Email uses the semantic field mappings below to generate the body of an email.
  SolrDocument.use_extension(Blacklight::Document::Email)

  # SMS uses the semantic field mappings below to generate the body of an SMS email.
  SolrDocument.use_extension(Blacklight::Document::Sms)

  # DublinCore uses the semantic field mappings below to assemble an OAI-compliant Dublin Core document
  # Semantic mappings of solr stored fields. Fields may be multi or
  # single valued. See Blacklight::Document::SemanticFields#field_semantics
  # and Blacklight::Document::SemanticFields#to_semantic_values
  # Recommendation: Use field names from Dublin Core
  use_extension(Blacklight::Document::DublinCore)

  # Do content negotiation for AF models. 

  use_extension( Hydra::ContentNegotiation )

  def composer
    self[Solrizer.solr_name('composer')]
  end

  def performer
    self[Solrizer.solr_name('performer')]
  end

  def instruments
    self[Solrizer.solr_name('instruments')]
  end

  def date
    self[Solrizer.solr_name('date')]
  end

  def tags
    self[Solrizer.solr_name('tags')]
  end

  def length
    self[Solrizer.solr_name('length')]
  end

  def genre
    self[Solrizer.solr_name('genre')]
  end

  def software
    self[Solrizer.solr_name('software')]
  end

  def medium
    self[Solrizer.solr_name('medium')]
  end

  def location
    self[Solrizer.solr_name('location')]
  end
end
