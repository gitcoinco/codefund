defmodule Framework.FileStorageTest do
  use ExUnit.Case

  describe "store/1" do
    test "it stores the asset in s3 and returns {:ok, filename, bucket} for saving" do
      {:ok, filename, bucket} =
        %Plug.Upload{
          content_type: "image/jpeg",
          path: Path.expand("../../test/support/mock.jpg", __DIR__),
          filename: "mock.jpg"
        }
        |> Framework.FileStorage.store()

      assert filename =~ "mock.jpg"
      assert bucket == "stub"
    end

    test "it returns {:error, :invalid_file_type} if the file isn't a jpg, png or gif" do
      assert %Plug.Upload{
               content_type: "image/pdf",
               path: Path.expand("../../test/support/mock.pdf", __DIR__),
               filename: "mock.pdf"
             }
             |> Framework.FileStorage.store() == {:error, :invalid_file_type}
    end
  end

  describe "url/3" do
    test "it returns the signed s3 url for the asset" do
      assert Framework.FileStorage.url("bucket", "stub.jpg") =~
               "http://localhost:4567/bucket/stub.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=123"
    end

    test "it returns nil if bucket or object is nil" do
      refute Framework.FileStorage.url(nil, "stub")
      refute Framework.FileStorage.url("stub", nil)
      refute Framework.FileStorage.url(nil, nil)
    end
  end
end
