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



