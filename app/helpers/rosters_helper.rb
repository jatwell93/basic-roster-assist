module RostersHelper
  def budget_status_color(is_customized)
    is_customized ? "bg-green-50 border-green-200" : "bg-blue-50 border-blue-200"
  end

  def budget_status_text_color(is_customized)
    is_customized ? "text-green-900" : "text-blue-900"
  end

  def budget_status_badge_color(is_customized)
    is_customized ? "bg-green-100 text-green-800" : "bg-blue-100 text-blue-800"
  end

  def format_currency(amount)
    amount.nil? ? "--" : number_to_currency(amount)
  end

  def format_percentage(percentage)
    percentage.nil? ? "--%" : "#{percentage}%"
  end

  def budget_status_label(is_customized)
    is_customized ? "Customized" : "Baseline"
  end
end
