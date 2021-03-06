require "fast_spec_helper"
require "remove_manual_document_service"

RSpec.describe RemoveManualDocumentService do
  let(:document_id) { "123" }

  let(:manual) {
    double(
      draft: nil,
      documents: [
        document,
      ],
      remove_document: nil,
    )
  }

  let(:repository) {
    double(
      fetch: manual,
      store: nil,
    )
  }

  let(:service_context) {
    double(
      params: {
        "id" => document_id,
        "manual_id" => "ABC",
        "document" => change_note_params
      },
    )
  }

  let(:listener) { spy(call: nil) }

  let(:service) {
    described_class.new(
      repository,
      service_context,
      listeners: [listener],
    )
  }

  context "with a document id that doesn't belong to the manual" do
    let(:document) {
      double(id: document_id)
    }
    let(:manual) {
      double(
        draft: nil,
        documents: [],
        remove_document: nil,
      )
    }
    let(:change_note_params) do
      {
        "minor_update" => "0",
        "change_note" => "Make a change"
      }
    end

    it "raises a ManualDocumentNotFound error" do
      expect {
        service.call
      }.to raise_error(described_class::ManualDocumentNotFoundError, document_id)
    end

    it "does not mark the manual as a draft" do
      begin; service.call; rescue; end
      expect(manual).not_to have_received(:draft)
    end

    it "does not notifies its listeners" do
      begin; service.call; rescue; end
      expect(listener).not_to have_received(:call)
    end
  end

  context "with invalid change_note params" do
    let(:document) {
      double(
        id: document_id,
        published?: true,
        update: nil,
        valid?: false,
      )
    }
    let(:change_note_params) do
      {
        "minor_update" => "1",
        "change_note" => "",
      }
    end

    before do
      service.call
    end

    it "tries to save the change note to the document" do
      expect(document).to have_received(:update).with(change_note_params)
    end

    it "does not removes the section" do
      expect(manual).not_to have_received(:remove_document).with(document.id)
    end

    it "does not mark the manual as a draft" do
      expect(manual).not_to have_received(:draft)
    end

    it "does not persists the manual" do
      expect(repository).not_to have_received(:store).with(manual)
    end

    it "does not notify its listeners" do
      expect(listener).not_to have_received(:call).with(document, manual)
    end
  end

  context "with valid change_note params" do
    let(:change_note_params) do
      {
        "minor_update" => "0",
        "change_note" => "Make a change"
      }
    end

    context "with a section that's previously been published" do
      let(:document) {
        double(
          id: document_id,
          published?: true,
          update: nil,
          valid?: true,
        )
      }

      before do
        service.call
      end

      it "saves the change note to the document" do
        expect(document).to have_received(:update).with(change_note_params)
      end

      it "removes the section" do
        expect(manual).to have_received(:remove_document).with(document.id)
      end

      it "marks the manual as a draft" do
        expect(manual).to have_received(:draft)
      end

      it "persists the manual" do
        expect(repository).to have_received(:store).with(manual)
      end

      it "notifies its listeners" do
        expect(listener).to have_received(:call).with(document, manual)
      end
    end

    context "with a section that's never been published" do
      let(:document) {
        double(
          id: document_id,
          published?: false,
          update: nil,
          valid?: true,
        )
      }

      before do
        service.call
      end

      it "saves the change note to the document" do
        expect(document).to have_received(:update).with("minor_update" => "0", "change_note" => "Make a change")
      end

      it "removes the section" do
        expect(manual).to have_received(:remove_document).with(document_id)
      end

      it "marks the manual as a draft" do
        # NOTE - this isn't neccesary really, but we do it to be consistent
        expect(manual).to have_received(:draft)
      end

      it "persists the manual" do
        expect(repository).to have_received(:store).with(manual)
      end

      it "notifies its listeners" do
        expect(listener).to have_received(:call).with(document, manual)
      end
    end

    context "with extra document params" do
      let(:document) {
        double(
          id: document_id,
          published?: true,
          update: nil,
          valid?: true,
        )
      }
      let(:change_note_params) do
        {
          "minor_update" => "0",
          "change_note" => "Make a change",
          "title" => "Sneakily try to change this"
        }
      end

      before do
        service.call
      end

      it "only saves the change note params to the document ignoring others" do
        expect(document).to have_received(:update).with(change_note_params.slice("change_note", "minor_update"))
      end
    end
  end
end
