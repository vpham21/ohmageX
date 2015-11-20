@Ohmage.module "Entities", (Entities, App, Backbone, Marionette, $, _) ->

	currentDeferred = []
	currentIndices = []

	API =
		downloadClassCampaigns: (collection) ->
			console.log "downloading class campaigns"
			oldLength = collection.length

			currentDeferred = []
			currentIndices = []

			currentDeferred = collection.map( (item, key) ->
				currentIndices.push(item.get 'id')
				return new $.Deferred()
			)

			$.when( currentDeferred... ).done =>
				@whenComplete(oldLength)

			collection.each( (item) ->
				console.log 'downloading ' + item.get('id') + ': ' + JSON.stringify(item)
				#if ~item.get('id').indexOf 'urn:campaign:ucla:runstrong'
					#App.execute "campaign:save", item
			)
			
			App.navigate "settings_date", { trigger: true }

		whenComplete: (oldLength) ->
			newLength = 0

			if newLength is 0
				App.execute "notice:show",
					data:
						title: "Download Success"
						description: "All surveys downloaded successfully."
						showCancel: false
			else
				App.execute "notice:show",
					data:
						title: "Download Failure"
						description: "#{newLength} out of #{oldLength} surveys failed to download."
						showCancel: false


	App.vent.on "campaigns:sync:success", (collection) ->
		API.downloadClassCampaigns collection