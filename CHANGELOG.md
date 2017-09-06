Workarea Avatax 3.0.1 (2017-09-06)
--------------------------------------------------------------------------------

*   Update vendored version of avatax gem

    Update vendored avatax gem. there's still some problems preventing use
    of the cut version, notable it returning hashie mash responses instead
    of faraday responses.  memoize .resposne on a tax request to stop it
    from creating a transaction everytime the response is accessed.

    AVATAX-22
    Eric Pigeon

*   Fix bugs with commiting a tax transaction.

    Commit fixes to tax worker to use correct symbolized keys on transaction.
    fix bug with improper response reference on the invoice worker

    AVATAX-22
    Jeff Yucis


Workarea Avatax 3.0.0 (2017-07-06)
--------------------------------------------------------------------------------

*   Update configuration and readme

    Allow the endpoint to be set via secrets so apps and easily configure
    their staging environments.  Fix error sending money object instead of
    string in rest call.  Add timeout to faraday

    AVATAX-20
    Eric Pigeon

*   Upgrade avatax for Workarea v3

    Upgrade the avatax to use the newer version 2 rest api.  They haven't
    publicly released them gem so it's currently vendored into lib/avatax.
    Update the tax calculator to build from price adjustments on the order
    and store tax adjustments on the shipping to mirror how it works in
    version 3.

    AVATAX-20
    Eric Pigeon
