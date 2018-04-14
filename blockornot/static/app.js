(function() {
  function reducer(state = {}, action) {
    var result;

    switch (action.type) {
      case "WEBSITE_UPDATE":
        result = website_update(state, action);
        break;
      case "CATEGORY_UPDATE":
        result = category_update(state, action);
        break;
      default:
        result = state;
    }

    return result;
  }

  function category_update(state, action) {
    return _.assign({}, state, {
      category: _.assign(
        {},
        state.category,
        _.object([[action.category.category_id, action.category]])
      )
    });
  }

  function website_update(state, action) {
    return _.assign({}, state, {
      website: _.assign(
        {},
        state.website,
        _.object([[action.website.website_uri, action.website]])
      )
    });
  }

  function make_category_update(category) {
    return {
      type: "CATEGORY_UPDATE",
      category: category
    };
  }

  function make_website_update(website) {
    return {
      type: "WEBSITE_UPDATE",
      website: website
    };
  }

  /**
   * Mimic the connect() for react-redux
   */
  var connect = _.partial(function(store, state_mapper, dispatcher_mapper) {
    return function($element) {
      return $element
        .data("store", store)
        .on("redux:dispatch", function(e, action) {
          e.preventDefault();

          store.dispatch(action);
        })
        .on("redux:mapper_update", function(e) {
          e.preventDefault();

          var incoming = state_mapper
            ? state_mapper.call(this, store.getState())
            : null;

          state_mapper && $(this).data(incoming);

          if (!_.isEqual($(this).data("__current__"), incoming)) {
            $(this).trigger("redux:render");
          }

          $(this).data("__current__", incoming);
        })
        .each(function() {
          $(this).data("__current__", null);

          store.subscribe(
            _.bind($(this).trigger, $(this), "redux:mapper_update")
          );

          dispatcher_mapper &&
            _.mapObject(
              dispatcher_mapper(store.dispatch),
              function(handler, event) {
                $(this).on(event, _.bind(handler, this));
              },
              this
            );
        });
    };
  }, Redux.createStore(reducer));

  connect(
    function(state) {
      return {
        website: _.filter(
          state.website,
          _.bind(function(website) {
            return (
              website.category_id ===
              $(this)
                .closest(".category")
                .data("_category_id")
            );
          }, this)
        )
      };
    },
    function(dispatch) {
      return {
        click: function(e) {
          e.preventDefault();

          _.each(
            $(this).data("website"),
            function(website) {
              $.get({
                url: "https://api.ooni.io/api/v1/measurements",
                data: {
                  probe_cc: website.country,
                  input: website.search_input
                },
                success: function(data) {
                  dispatch(
                    make_website_update(
                      _.assign({}, website, {
                        anomaly: data.results[0].anomaly,
                        failure: data.results[0].failure,
                        confirmed: data.results[0].confirmed,
                        time: data.results[0].measurement_start_time
                      })
                    )
                  );
                }
              });
            },
            this
          );
        }
      };
    }
  )($(".category .refresh"));

  connect()($(".category")).each(function() {
    $(this).trigger(
      "redux:dispatch",
      make_category_update({
        category_id: $(this).data("_category_id"),
        name: $(this).data("_name")
      })
    );
  });

  connect(
    function(state) {
      return {
        website: state.website[$(this).data("_website_uri")] || false
      };
    },
    function(dispatch) {
      return {
        "redux:render": function() {
          if ($(this).data("website")) {
            $(this)
              .empty()
              .append(
                $(
                  '<td><a href="http://' +
                    $(this).data("website").website_uri +
                    '">' +
                    $(this).data("website").website_uri +
                    "</a></td>"
                )
              )
              .append(
                $(
                  '<td class="time">' +
                    moment($(this).data("website").time).fromNow() +
                    "</td>"
                )
              )
              .trigger("app:render_status");
          }
        },
        "app:render_status": function() {
          if ($(this).data("website")) {
            if ($(this).data("website").anomaly) {
              $(this).append(
                $("<td>BLOCK</td>").addClass(
                  "red lighten-5 red-text text-darken-4"
                )
              );
            } else {
              $(this).append(
                $("<td>OK</td>").addClass(
                  "green lighten-5 green-text text-darken-4"
                )
              );
            }
          }
        }
      };
    }
  )($(".category tbody tr")).each(function() {
    var _data = $(this).data();
    $(this).trigger(
      "redux:dispatch",
      make_website_update({
        website_uri: _data._website_uri,
        search_input: _data._search_input,
        category_id: _data._category_id,
        time: _data._time,
        confirmed: _data._confirmed === "True",
        anomaly: _data._anomaly === "True",
        failure: _data._failure === "True"
      })
    );
  });
})();
