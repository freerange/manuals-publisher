require "formatters/abstract_specialist_document_indexable_formatter"

class AsylumSupportDecisionIndexableFormatter < AbstractSpecialistDocumentIndexableFormatter
  def type
    "asylum_support_decision"
  end

private
  def extra_attributes
    {
      tribunal_decision_decision_date: entity.tribunal_decision_decision_date,
      tribunal_decision_judges: entity.tribunal_decision_judges,
      tribunal_decision_category: entity.tribunal_decision_category,
      tribunal_decision_sub_category: entity.tribunal_decision_sub_category,
      tribunal_decision_landmark: entity.tribunal_decision_landmark,
      tribunal_decision_reference_number: entity.tribunal_decision_reference_number,
    }
  end

  def organisation_slugs
    ["first-tier-tribunal-asylum-support"]
  end
end
