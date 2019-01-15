module AnalyticsHelper
  def analytics_chart_inputs(chart_id, default_range=nil, default_granularity=nil)
    content_tag :div, class: "analytics-inputs" do
      concat(content_tag(:div) do
        concat label_tag("#{chart_id}-range", "Range: ")
        concat select_tag("range", options_for_select(Analytics.configuration.default_range_options_for_select, default_range), data: {for_chart: chart_id, select: "range"}, id: "#{chart_id}-range" )
      end)
      concat(content_tag(:div) do
        concat label_tag("#{chart_id}-granularity", "Granularity: ")
        concat select_tag("granularity", options_for_select(Analytics.configuration.default_granularity_options_for_select, default_granularity), data: {for_chart: chart_id, select: "granularity"}, id: "#{chart_id}-granularity" )
      end)
      concat link_to "Refresh", "#", data: {refresh_chart: chart_id}, class: "button"
    end
  end

  def analytics_switcher_option(path, label, term)
    content_tag :option, 'data-path': path, selected: ('selected' if current_page?(path)) do "#{(term_for term)} Analytics"
    end
  end
end
