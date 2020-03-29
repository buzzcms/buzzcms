defmodule BuzzcmsWeb.Resolver do
  defmacro __using__(_opts) do
    quote do
      alias Buzzcms.Repo
      alias BuzzcmsWeb.ResolverHelper
      import Ecto.Query

      def list(params, %{context: _} = _info) do
        ResolverHelper.list(
          params,
          @schema,
          @filter_definition,
          []
        )
      end

      def create(params, info) do
        ResolverHelper.create(@schema, params, info)
      end

      def edit(params, info) do
        ResolverHelper.edit(@schema, params, info)
      end

      def delete(params, info) do
        ResolverHelper.delete(@schema, params, info)
      end

      defoverridable list: 2
    end
  end
end
