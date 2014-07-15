class AbstractDocumentsController < ApplicationController
  before_filter :authorize_user

  rescue_from("SpecialistDocumentRepository::NotFoundError") do
    redirect_to(index_path, flash: { error: "Document not found" })
  end

  def index
    documents = Kaminari.paginate_array(services.list.call).page(params[:page])

    render(:index, locals: { documents: documents.map { |d| view_adapter(d) } })
  end

  def show
    document = services.show(document_id).call

    render(:show, locals: { document: view_adapter(document) })
  end

  def new
    document = services.new.call

    render(:new, locals: { document: view_adapter(document) })
  end

  def edit
    document = services.show(document_id).call

    render(:edit, locals: { document: view_adapter(document) })
  end

  def create
    document = services.create(document_params).call

    if document.valid?
      redirect_to(show_path(document))
    else
      render(:new, locals: { document: view_adapter(document) })
    end
  end

  def update
    document = services.update(document_id, document_params).call

    if document.valid?
      redirect_to(show_path(document))
    else
      render(:edit, locals: { document: view_adapter(document) })
    end
  end

  def publish
    document = services.publish(document_id).call

    redirect_to(
      show_path(document),
      flash: { notice: "Published #{document.title}" }
    )
  end

  def withdraw
    document = services.withdraw(document_id).call

    redirect_to(
      show_path(document),
      flash: { notice: "Withdrawn #{document.title}" }
    )
  end

  def preview
    preview_html = services.preview(params["id"], document_params).call

    render json: { preview_html: preview_html }
  end

private
  def document_id
    params.fetch("id")
  end

  def document_params
    raise NotImplementedError
  end

  def view_adapter(document)
    raise NotImplementedError
  end

  def authorize_user
    raise NotImplementedError
  end

  def services
    raise NotImplementedError
  end

  def index_path
    raise NotImplementedError
  end

  def show_path(document)
    raise NotImplementedError
  end
end
