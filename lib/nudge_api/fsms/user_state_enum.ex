defmodule NudgeApi.Fsms.UserStateEnum do
  use EctoEnum,
    incomplete: "incomplete",
    disabled: "disabled",
    banned: "banned",
    waiting_match: "waiting_match",
    has_match: "has_match",
    in_match: "in_match",
    waiting_video_call: "waiting_video_call",
    has_video_call: "has_video_call",
    in_video_call: "in_video_call",
    waiting_meeting: "waiting_meeting",
    waiting_meeting_plan: "waiting_meeting_plan",
    has_meeting: "has_meeting",
    in_meeting: "in_meeting"

  def values do
    __enum_map__() |> Enum.map(fn {val, _} -> val end)
  end
end
