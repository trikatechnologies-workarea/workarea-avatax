# only run if there are no UsageTypes already inserted
if Weblinc::Avatax::UsageType.count == 0
  defaults = [
    { code: 'A', name: 'Federal Government (US)' },
    { code: 'B', name: 'State Government (US)' },
    { code: 'C', name: 'Tribe / Status Indian / Indian Band (both)' },
    { code: 'D', name: 'Foreign diplomat (both)' },
    { code: 'E', name: 'Charitable or benevolent org (both)' },
    { code: 'F', name: 'Religious or educational org (both)' },
    { code: 'G', name: 'Resale (both)' },
    { code: 'H', name: 'Commercial agricultural production (both)' },
    { code: 'I', name: 'Industrial production / manufacturer (both)' },
    { code: 'J', name: 'Direct pay permit (US)' },
    { code: 'K', name: 'Direct mail (US)' },
    { code: 'L', name: 'Other (both)' },
    { code: 'N', name: 'Local government (US)' },
    { code: 'P', name: 'Commercial aquaculture (Canada)' },
    { code: 'Q', name: 'Commercial Fishery (Canada)' },
    { code: 'R', name: 'Non-resident (Canada)' },
  ]

  defaults.each do |params|
    Weblinc::Avatax::UsageType.create(params)
  end
end
