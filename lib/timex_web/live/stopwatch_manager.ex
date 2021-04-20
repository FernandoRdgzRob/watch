defmodule TimexWeb.StopwatchManager do
  use GenServer

  def init(ui) do
    :gproc.reg({:p, :l, :ui_event})
    GenServer.cast(ui, {:set_time_display, "00:00.00"})
    {:ok, %{ui_pid: ui, count: ~T[00:00:00.00], st: Paused}}
  end

  def handle_info(:"bottom-right", %{ui_pid: _ui, st: Paused} = state) do
    timer = Process.send_after(self(), :timerCounting, 10)
    {:noreply, %{state | st: Counting}}
  end

  def handle_info(:timerCounting, %{ui_pid: ui, count: count, st: Counting} = state) do
    count = Time.add(count, 10, :millisecond)
    str = count
    |> Time.truncate(:millisecond)
    |> Time.to_string
    |> String.slice(3, 8)
    GenServer.cast(ui, {:set_time_display, str})
    timer = Process.send_after(self(), :timerCounting, 10)
    {:noreply, %{state | count: count, st: Counting}}
  end

  def handle_info(:"bottom-right", %{ui_pid: _ui, st: Counting} = state) do
    {:noreply, %{state | st: Paused}}
  end

  def handle_info(_, state) do
    {:noreply, state}
  end

end