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
				cell = $("""
				<td>
					<button class='down'>-</button>
					<input type='number' step='1' min='1' max='10'>
					<button class='up'>+</button>
				</td>
				""")
				$(".up", cell).click((e) ->
					try
						node = $(this).siblings('input')[0]
						if node.value == ""
							node.value = $(node).attr('min')
						else
							node.stepUp()
					catch e
						return
				)
				$(".down", cell).click((e) ->
					try
						node = $(this).siblings('input')[0]
						if node.value == ""
							node.value = $(node).attr('max')
						else
							node.stepDown()
					catch e
						return
				)
				row.append(cell)
			tbody.append(row)
		
		return @
