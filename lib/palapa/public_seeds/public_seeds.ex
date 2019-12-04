defmodule Palapa.PublicSeeds do
  alias Palapa.Messages

  def seed(organization, locale) do
    Messages.create_system_message(organization, message_data(locale))
  end

  def message_data("fr") do
    %{
      title: "Bienvenue dans votre nouvel espace !",
      content: """
      <h1>Invitez du monde</h1><div>Ne restez pas là tout seul ! Vous pouvez inviter d&apos;autres personnes à rejoindre votre espace dans le menu <strong>&quot;Equipes &gt; Inviter des personnes&quot;</strong>. Ils recevront un email pour s&apos;inscrire à leur tour et auront accès à cet espace.<br/><br/>Si vous le souhaitez, vous pourrez ensuite répartir les membres dans différentes équipes pour mieux contrôler qui voit quoi et éviter de solliciter les personnes non concernées.</div><h1>Quoi de neuf ?</h1><div>Vous pouvez poster des messages comme celui-ci dans la section <strong>&quot;Quoi de neuf ?&quot;</strong> pour partager des actualités ou des idées avec les autres membres de l&apos;espace de travail. Vous pouvez aussi utiliser cette section comme un blog interne pour votre entreprise ou comme un forum.<br/><br/>Si vous avez créé des équipes, vous pourrez choisir quelles équipes verront vos messages.<br/><br/></div><h1>Une question ? Besoin d&apos;aide ?</h1><div>N&apos;hésitez pas à nous envoyer un mail à <a href="mailto:support@palapa.io">support@palapa.io</a> si vous avez besoin de quoi que ce soit.<br/><br/>Bonne découverte !</div>
      """
    }
  end

  def message_data(_) do
    %{
      title: "Welcome to your new workspace!",
      content: """
      <h1>Invite people</h1><div>Don&apos;t be alone! You can invite others to join your workspace in the <strong>&quot;Teams&quot;</strong> section.<br/>They will receive an email allowing them to register and access your workspace.<br/><br/>If you wish, you can then dispatch the members into different teams to better control who sees what and avoid soliciting people who are not involved.</div><h1>What&apos;s up?</h1><div>You can post messages like this in the &quot;What&apos;s New&quot; section to share news or ideas with other workspace members. You can also use this section as an internal blog for your company or as a forum.<br/><br/>If you have created teams, you will be able to choose which teams will see your messages.<br/><br/></div><h1>Need help?</h1><div>Feel free to send us an email at support@palapa.io if you need anything.<br/><br/>Happy discovery!</div>
      """
    }
  end
end
