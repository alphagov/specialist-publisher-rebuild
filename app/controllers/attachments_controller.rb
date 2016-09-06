class AttachmentsController < ApplicationController
  before_action :check_authorisation, if: :document_type_slug

  def check_authorisation
    authorize current_format
  end

  def new
    @document = fetch_document
    @attachment = Attachment.new
  end

  def create
    document = fetch_document

    if attachment_valid?
      attachment = document.attachments.build(attachment_params)
      attachment.content_type = attachment.file.content_type

      upload_attachment(document, attachment)
    else
      flash[:danger] = "Adding an attachment failed. Please make sure you have uploaded an attachment."
      redirect_to new_document_attachment_path(document_type_slug, document.content_id)
    end
  end

  def edit
    @document = fetch_document
    @attachment = @document.attachments.find(attachment_content_id)
  end

  def update
    document = fetch_document
    attachment = document.attachments.find(attachment_content_id)
    attachment.update_attributes(attachment_params)

    if attachment.file.nil?
      save_updated_title(document, attachment)
    else
      update_attachment(document, attachment)
    end
  end

private

  def save_updated_title(document, attachment)
    if document.save(validate: false)
      flash[:success] = "Attachment succesfully updated"
      redirect_to edit_document_path(document_type_slug, document.content_id)
    else
      flash[:danger] = "There was an error updating the title, please try again later."
      redirect_to edit_document_attachment_path(document_type_slug, document.content_id, attachment.content_id)
    end
  end

  def update_attachment(document, attachment)
    if document.update_attachment(attachment)
      flash[:success] = "Updated #{attachment.title}"
      redirect_to edit_document_path(document_type_slug, document.content_id)
    else
      flash[:danger] = "There was an error updating the attachment, please try again later."
      redirect_to edit_document_attachment_path(document_type_slug, document.content_id, attachment.content_id)
    end
  end

  def upload_attachment(document, attachment)
    if document.upload_attachment(attachment)
      flash[:success] = "Attached #{attachment.title}"
      redirect_to edit_document_path(document_type_slug, document.content_id)
    else
      flash[:danger] = "There was an error uploading the attachment, please try again later."
      redirect_to new_document_attachment_path(document_type_slug, document.content_id)
    end
  end

  def fetch_document
    document = current_format.find(params[:document_content_id])
    document.set_temporary_update_type!
    document
  rescue Document::RecordNotFound => e
    flash[:danger] = "Document not found"
    redirect_to documents_path(document_type_slug: document_type_slug)

    Airbrake.notify(e)
  end

  def attachment_content_id
    params[:attachment_content_id]
  end

  def attachment_params
    params.require(:attachment).permit(:title, :file)
  end

  def attachment_valid?
    !params["attachment"].nil? && !params["attachment"]["file"].nil?
  end
end
