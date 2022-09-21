defmodule PhxLiveStorybook.Rendering.CodeRendererTest do
  use ExUnit.Case, async: true

  alias PhxLiveStorybook.TreeStorybook

  setup_all do
    [
      component: TreeStorybook.load_story("/component", validate: false),
      live_component: TreeStorybook.load_story("/live_component", validate: false),
      afolder_component: TreeStorybook.load_story("/a_folder/component", validate: false),
      afolder_live_component:
        TreeStorybook.load_story("/a_folder/live_component", validate: false),
      template_component:
        TreeStorybook.load_story("/templates/template_component", validate: false)
    ]
  end

  describe "render_variation_code/2" do
    test "it should return HEEX for each component/variation couple", %{
      component: component,
      live_component: live_component
    } do
      code = render_variation_code(component, :hello)
      assert code =~ ~r|<pre.*</pre>|s

      code = render_variation_code(component, :world)
      assert code =~ ~r|<pre.*</pre>|s

      code = render_variation_code(live_component, :hello)
      assert code =~ ~r|<pre.*</pre>|s

      code = render_variation_code(live_component, :world)
      assert code =~ ~r|<pre.*</pre>|s
    end

    test "it also works for a variation group", %{
      afolder_component: component,
      afolder_live_component: live_component
    } do
      code = render_variation_code(component, :group)
      assert code =~ ~r|<pre.*</pre>|s

      code = render_variation_code(live_component, :group)
      assert code =~ ~r|<pre.*</pre>|s
    end

    test "it is working with a variation without any attributes", %{afolder_component: component} do
      code = render_variation_code(component, :no_attributes)
      assert code =~ ~r|<pre.*</pre>|s
    end

    test "it is working with an inner_block requiring a let attribute" do
      component = TreeStorybook.load_story("/let/let_component", validate: false)
      code = render_variation_code(component, :default)
      assert code =~ ~r|<pre.*</pre>|s
    end

    test "it is working with an inner_block requiring a let attribute, in a live component" do
      component = TreeStorybook.load_story("/let/let_live_component", validate: false)
      code = render_variation_code(component, :default)
      assert code =~ ~r|<pre.*</pre>|s
    end

    test "it is working with a template component" do
      component = TreeStorybook.load_story("/templates/template_component", validate: false)
      code = render_variation_code(component, :hello)
      assert Regex.match?(~r/<pre.*template-div.*\/pre>/s, code)
    end

    test "it prints aliases struct names" do
      component = TreeStorybook.load_story("/b_folder/all_types_component", validate: false)
      code = render_variation_code(component, :with_struct)
      assert Regex.match?(~r/<pre.*Struct.*\/pre>/s, code)
      refute Regex.match?(~r/<pre.*AllTypesComponent.*\/pre>/s, code)
    end
  end

  defp render_variation_code(story, variation_id) do
    PhxLiveStorybook.Rendering.CodeRenderer.render_variation_code(story, variation_id)
    |> Phoenix.LiveViewTest.rendered_to_string()
  end
end