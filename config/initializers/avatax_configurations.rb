Workarea::Configuration.define_fields do
  fieldset 'Avatax', namespaced: false do
    field 'Default Avatax Code',
      type: :string,
      default: "P0000000",
      description: "If a product doesn't have any tax code, this code will be consitered for calculating tax"
  end
end