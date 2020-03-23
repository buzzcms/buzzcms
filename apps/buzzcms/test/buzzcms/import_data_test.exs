defmodule Buzzcms.DataImporterTest do
  use Buzzcms.DataCase
  alias Buzzcms.DataImporter

  describe("data importer") do
    test "import data" do
      DataImporter.import_from_dir(Path.join(File.cwd!(), "sample_data"))
    end
  end
end
