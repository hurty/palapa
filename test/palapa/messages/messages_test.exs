defmodule Palapa.MessagesTest do
  use Palapa.DataCase

  import Palapa.Factory
  alias Palapa.Messages
  alias Palapa.Messages.Message

  test "create/3 with a public message" do
    organization = insert!(:organization)
    member = insert!(:member, organization: organization)

    assert {:ok, %Message{}} =
             Messages.create(member, %{title: "Hello World", content: "<h1>Hello</h1"}, nil)
  end

  test "create/3 with a message for a specific team" do
    organization = insert!(:organization)
    member = insert!(:member, organization: organization)
    team = insert!(:team, organization: organization)

    assert {:ok, %Message{}} =
             Messages.create(member, %{title: "Hello World", content: "<h1>Hello</h1"}, [team])
  end

  test "create/3 sanitize the message content and removes dangerous stuff" do
    organization = insert!(:organization)
    member = insert!(:member, organization: organization)

    message_content = %{
      title: "Hello World",
      content:
        ~s(<h1>Hello</h1><unknown>Stuff</unknown><script src="https://stackpath.bootstrapcdn.com/bootstrap/4.1.1/js/bootstrap.min.js" integrity="sha384-smHYKdLADwkXOn1EmN1qk/HfnUcbVRZyYmZ4qpPea6sjB/pTJ0euyQp0Mk8ck+5T" crossorigin="anonymous"></script>)
    }

    assert {:ok, %Message{} = message} = Messages.create(member, message_content, nil)

    assert "<h1>Hello</h1>Stuff" == message.content
  end

  test "create/3 keeps all supported tags in message content" do
    organization = insert!(:organization)
    member = insert!(:member, organization: organization)

    message_content = %{
      title: "Hello World",
      content:
        ~s(<h1>Title</h1><div><strong>Bold stuff</strong><br /><em>italic</em><br /><del>stroke</del><br /><a href="http://www.qwant.com">A link</a></div><blockquote>quote</blockquote><pre>code</pre><ul><li>list</li></ul><ol><li>listnumbers</li></ol>)
    }

    assert {:ok, %Message{} = message} = Messages.create(member, message_content, nil)

    assert ~s(<h1>Title</h1><div><strong>Bold stuff</strong><br /><em>italic</em><br /><del>stroke</del><br /><a href="http://www.qwant.com">A link</a></div><blockquote>quote</blockquote><pre>code</pre><ul><li>list</li></ul><ol><li>listnumbers</li></ol>) ==
             message.content
  end
end
