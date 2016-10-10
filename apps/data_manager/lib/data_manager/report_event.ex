defmodule DataManager.Report.Event do
  @behaviour :exometer_report
  require Logger

  def exometer_init(opts) do
    #Logger.info("Report Options: #{inspect opts}")
    {:ok, {}}
  end

  def exometer_subscribe(metric, datapoint, interval, state) do
    #Logger.info("Report Subscribe: #{inspect metric} - #{inspect datapoint} - #{inspect interval} - #{inspect state}")
    {:ok, state}
  end

  def exometer_subscribe(metric, datapoint, interval, extra, state) do
    #Logger.info("Report Subscribe: #{inspect metric} - #{inspect datapoint} - #{inspect interval} - #{inspect extra} - #{inspect state}")
    {:ok, state}
  end

  def exometer_report(metric, datapoint, extra, value, state) do
    Logger.debug("Report Report: #{inspect metric} - #{inspect datapoint} - #{inspect extra} - #{inspect value}")
    %{
      metric: metric,
      datapoint: datapoint,
      extra: extra,
      value: value
    } |> DataManager.Broadcaster.sync_notify
    {:ok, state}
  end

  def exometer_report(metric, datapoint, state) do
    #Logger.info("Report Report: #{inspect metric} - #{inspect datapoint} - #{inspect state}")
    {:ok, state}
  end

  def exometer_unsubscribe(metric, datapoint, state) do
    #Logger.info("Report Unsubscribe: #{inspect metric} - #{inspect datapoint} - #{inspect state}")
    {:ok, state}
  end

  def exometer_report_bulk(found, extra, state) do
    #Logger.info("Report Report Bulk: #{inspect found} - #{inspect extra} - #{inspect state}")
    {:ok, state}
  end

  def exometer_newentry(_entry, state) do
    {:ok, state}
  end

end
