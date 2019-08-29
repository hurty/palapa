defmodule Palapa.Factory do
  alias Palapa.Repo

  alias Palapa.Organizations.{Organization, Member, MemberInformation}
  alias Palapa.Billing.{Customer, Invoice, Subscription}
  alias Palapa.Accounts.Account
  alias Palapa.Teams.Team

  #
  # Convenience functions
  #

  def build(factory_name, attrs) do
    build(factory_name) |> struct(attrs)
  end

  def insert!(factory_name, attrs \\ []) do
    build(factory_name, attrs)
    |> Repo.insert!()
  end

  def random_integer do
    System.unique_integer([:positive])
  end

  @password_hash Comeonin.Bcrypt.hashpwsalt("password")

  #
  # Factories
  #

  def insert_pied_piper!() do
    # -- Organization
    pied_piper = insert!(:organization)

    customer = insert!(:customer, organization: pied_piper)
    subscription = insert!(:subscription, organization: pied_piper, customer: customer)

    # -- Members
    richard = insert!(:owner, organization: pied_piper)
    jared = insert!(:admin, organization: pied_piper)
    gilfoyle = insert!(:member, organization: pied_piper)

    # -- Teams
    tech_team =
      insert!(:team, organization: pied_piper, name: "Tech", members: [richard, gilfoyle])

    management_team =
      insert!(:team, organization: pied_piper, name: "Management", members: [richard, jared])

    %{
      organization: pied_piper,
      customer: customer,
      subscription: subscription,
      richard: richard,
      jared: jared,
      gilfoyle: gilfoyle,
      tech_team: tech_team,
      management_team: management_team
    }
  end

  def insert_pied_piper!(:full) do
    # -- Organization
    pied_piper = insert!(:organization)

    customer = insert!(:customer, organization: pied_piper)
    _subscription = insert!(:subscription, organization: pied_piper, customer: customer)

    # -- Members
    richard =
      insert!(:owner,
        organization: pied_piper,
        member_informations: [
          %MemberInformation{
            label: "email",
            value: "richard.hendricks@piedpiper.com"
          },
          %MemberInformation{
            label: "My best quote",
            value: "Wahoo"
          }
        ]
      )

    jared =
      insert!(:admin,
        organization: pied_piper,
        title: "Head of Business Development",
        member_informations: [
          %MemberInformation{
            label: "email",
            value: "jared.dunn@piedpiper.com"
          },
          %MemberInformation{
            label: "Office hours",
            value: "Mon-Fri 9-5"
          },
          %MemberInformation{
            label: "My best quote",
            value: "How would you like to die today, motherfucker? "
          }
        ]
      )

    gilfoyle =
      insert!(:member,
        organization: pied_piper,
        title: "Nerd",
        member_informations: [
          %MemberInformation{
            label: "email",
            value: "bertram.gilfoyle@piedpiper.com"
          },
          %MemberInformation{
            label: "My best quote",
            value:
              "Our process sucks. Your inability to stop us from sucking is a failure of leadership."
          }
        ]
      )

    dinesh =
      insert!(:member,
        organization: pied_piper,
        account: build(:dinesh),
        title: "Developer",
        member_informations: [
          %MemberInformation{
            label: "email",
            value: "dinesh.chugtai@piedpiper.com"
          },
          %MemberInformation{
            label: "person to contact",
            value: "My girlfriend 06729824042"
          },
          %MemberInformation{
            label: "twitter",
            value: "https://twitter.com/dineshisreal"
          }
        ]
      )

    monica =
      insert!(:member,
        organization: pied_piper,
        account: build(:monica),
        title: "VC",
        member_informations: [
          %MemberInformation{
            label: "email",
            value: "monica.hall@piedpiper.com"
          },
          %MemberInformation{
            label: "office hours",
            value: "Mon-Fri 9-5"
          }
        ]
      )

    laurie = insert!(:member, organization: pied_piper, account: build(:laurie), title: "VC")
    ron = insert!(:member, organization: pied_piper, account: build(:ron), title: "Lawyer")

    big_head =
      insert!(:member, organization: pied_piper, account: build(:big_head), title: "Clueless guy")

    erlich =
      insert!(:member,
        organization: pied_piper,
        account: build(:erlich),
        title: "Roommate",
        member_informations: [
          %MemberInformation{
            label: "email",
            value: "erlich.bachman@piedpiper.com"
          },
          %MemberInformation{
            label: "person to contact",
            value: "My mum 06729824042"
          },
          %MemberInformation{
            label: "twitter",
            value: "https://twitter.com/erlichbachman"
          }
        ]
      )

    # -- Teams
    tech_team =
      insert!(:team, organization: pied_piper, name: "Tech", members: [richard, gilfoyle, dinesh])

    management_team =
      insert!(:team,
        organization: pied_piper,
        name: "Management",
        private: true,
        members: [richard, jared, monica, laurie]
      )

    vulture_team =
      insert!(:team,
        organization: pied_piper,
        name: "Vulture",
        members: [monica, big_head, erlich, laurie]
      )

    %{
      organization: pied_piper,
      richard: richard,
      jared: jared,
      gilfoyle: gilfoyle,
      dinesh: dinesh,
      monica: monica,
      big_head: big_head,
      erlich: erlich,
      ron: ron,
      tech_team: tech_team,
      management_team: management_team,
      vulture_team: vulture_team
    }
  end

  def insert_hooli!() do
    # -- Organization
    hooli = insert!(:organization)

    # -- Members
    gavin = insert!(:owner, organization: hooli, account: build(:gavin))

    %{
      organization: hooli,
      gavin: gavin
    }
  end

  def build(:organization) do
    %Organization{
      name: "Pied Piper"
    }
  end

  def build(:customer) do
    %Customer{
      stripe_customer_id: "cus_123",
      billing_name: "Richard Hendricks",
      billing_email: "richard@piedpiper.com",
      billing_address: "28 rue Saint Antoine",
      billing_city: "Nantes",
      billing_postcode: "44000",
      billing_state: "Loire Atlantique",
      billing_country: "France",
      vat_number: "vat_123"
    }
  end

  def build(:subscription) do
    %Subscription{status: :trialing, stripe_subscription_id: "sub_000"}
  end

  def build(:invoice) do
    %Invoice{
      stripe_invoice_id: "in_000",
      total: 2900,
      status: "open",
      number: "ABC123",
      hosted_invoice_url: "https://pay.stripe.com/invoice/invst_GkUH2ES1UzkOOc9L4Iip6xIQH2",
      pdf_url: "https://pay.stripe.com/invoice/invst_GkUH2ES1UzkOOc9L4Iip6xIQH2/pdf",
      created_at: DateTime.utc_now() |> DateTime.truncate(:second)
    }
  end

  def build(:member) do
    %Member{
      organization: build(:organization),
      account: build(:gilfoyle),
      role: :member,
      title: "Nerd"
    }
  end

  def build(:owner) do
    %Member{
      organization: build(:organization),
      account: build(:richard),
      role: :owner,
      title: "CEO"
    }
  end

  def build(:admin) do
    %Member{
      organization: build(:organization),
      account: build(:jared),
      role: :admin
    }
  end

  def build(:richard) do
    %Account{
      name: "Richard Hendricks",
      email: "richard.hendricks@piedpiper.com",
      password_hash: @password_hash
    }
  end

  def build(:jared) do
    %Account{
      name: "Jared Dunn",
      email: "jared.dunn@piedpiper.com",
      password_hash: @password_hash
    }
  end

  def build(:gilfoyle) do
    %Account{
      name: "Bertram Gilfoyle",
      email: "bertram.gilfoyle@piedpiper.com",
      password_hash: @password_hash
    }
  end

  def build(:dinesh) do
    %Account{
      name: "Dinesh Chugtai",
      email: "dinesh.chugtai@piedpiper.com",
      password_hash: @password_hash
    }
  end

  def build(:monica) do
    %Account{
      name: "Monica Hall",
      email: "monica.hall@piedpiper.com",
      password_hash: @password_hash
    }
  end

  def build(:laurie) do
    %Account{
      name: "Laurie Bream",
      email: "laurie.bream@piedpiper.com",
      password_hash: @password_hash
    }
  end

  def build(:big_head) do
    %Account{
      name: "Big Head",
      email: "nelson.bighetti@piedpiper.com",
      password_hash: @password_hash
    }
  end

  def build(:erlich) do
    %Account{
      name: "Erlich Bachman",
      email: "erlich.bachman@piedpiper.com",
      password_hash: @password_hash
    }
  end

  def build(:ron) do
    %Account{
      name: "Ron LaFlamme",
      email: "ron.laflamme@laflamme-lawyers.com",
      password_hash: @password_hash
    }
  end

  def build(:gavin) do
    %Account{
      name: "Gavin Belson",
      email: "gavin.belson@hooli.com",
      password_hash: @password_hash
    }
  end

  def build(:team) do
    %Team{
      organization: build(:organization),
      name: "Tech"
    }
  end
end
