class PreviewDocumentService
  def initialize(document_repository, document_builder, document_renderer, document_id, document_params)
    @document_repository = document_repository
    @document_builder = document_builder
    @document_renderer = document_renderer
    @document_id = document_id
    @document_params = document_params
  end

  def call
    document.update(document_params)
    document.valid? # Force validation check or errors will be empty

    if document.errors[:body].nil?
      document_renderer.call(document).body
    else
      document.errors[:body].map { |m|
        content_tag(:p, "Body #{m}")
      }
    end
  end

  private

  attr_reader(
    :document_repository,
    :document_builder,
    :document_renderer,
    :document_id,
    :document_params,
  )

  def document
    document_id ? existing_document : ephemeral_document
  end

  def ephemeral_document
    document_builder.call(document_params)
  end

  def existing_document
    @existing_document ||= document_repository.fetch(document_id)
  end
end
