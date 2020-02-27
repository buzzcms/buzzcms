defmodule Buzzcms.SignInWithEmailStruct do
  defstruct email: nil,
            password: nil

  use ExConstructor
end

defmodule Buzzcms.SignUpWithEmailStruct do
  defstruct email: nil,
            password: nil,
            display_name: nil,
            auth_provider: "email"

  use ExConstructor
end
