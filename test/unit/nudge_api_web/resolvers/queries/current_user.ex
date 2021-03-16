defmodule NudgeApiWeb.Resolvers.Queries.CurrentUserCase do
  use NudgeApiWeb.ConnCase, async: true

  @user_query """
  query currentUser {
    currentUser {
      id
    }
  }
  """

  test "query: currentUser", %{conn: conn} do
    conn =
      post(conn, "/api/graphql", %{
        "query" => @user_query
      })

    assert json_response(conn, 200) == %{
             "data" => %{"currentUser" => %{"id" => "1"}}
           }
  end
end
