_.templateSettings =
  interpolate: /\{\{(.+?)\}\}/g

@MAUT = Backbone.View.extend
	className: "maut"
	tagName: "table"

	solutions: []
	issues: []

	addSolution: (solution) ->
		@solutions.push(solution)

	addIssue: (issue) ->
		@issues.push(issue)
	
	initialize: (obj={}) ->
		@solutions = obj.solutions if obj.solutions instanceof Array
		@issues = obj.issues if obj.issues instanceof Array
	
	render: ->
		tbody = $("<tbody></tbody>")
		@$el.empty().append(tbody)

		row = $("<tr><td></td></tr>")
		for solution in @solutions
			row.append("<th>#{solution}</th>")
		tbody.append(row)

		for issue in @issues
			row = $("<tr><th>#{issue}</th></tr>")
			for i in [1..@solutions.length]
				cell = $("<td><label><input type='checkbox'></label></td>")
				row.append(cell)
			tbody.append(row)
		
		return @
