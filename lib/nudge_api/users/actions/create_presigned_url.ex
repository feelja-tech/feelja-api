defmodule NudgeApi.Users.Actions.CreatePresignedUrl do
  alias NudgeApi.Users.UserFile

  def handle(%UserFile{id: filename}, method) do
    case ExAws.Config.new(:s3)
         |> ExAws.S3.presigned_url(
           method,
           System.fetch_env!("S3_BUCKET_NAME"),
           to_string(filename),
           expires_in: 3600
         ) do
      {:ok, binary} -> binary
      {:error, binary} -> binary
    end
  end
end
