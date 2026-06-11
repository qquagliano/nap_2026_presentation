return {
	["glossary"] = function(raw_args)
		word = raw_args[1]
		def = raw_args[2]
		plural = raw_args[3]

		if quarto.doc.is_format("pdf") then
			if string.find(plural, "false") then
				block = pandoc.RawBlock(
					"tex",
					"\\newglossaryentry{"
						.. word
						.. "}{name={"
						.. word
						.. "},description={"
						.. def
						.. "}}"
						.. "\\mybox{\\gls{"
						.. word
						.. "}}"
				)
			end
			if string.find(plural, "true") then
				block = pandoc.RawBlock(
					"tex",
					"\\newglossaryentry{"
						.. word
						.. "}{name={"
						.. word
						.. "},description={"
						.. def
						.. "}}"
						.. "\\glspl{"
						.. word
						.. "}"
				)
			end
		end

		if quarto.doc.is_format("revealjs") then
			block = pandoc.RawBlock("html", "<b>" .. word .. "</b>")
		end

		if quarto.doc.is_format("html") then
			block = pandoc.RawBlock("html", "<b>" .. word .. "</b>")
		end

		return block
	end,
}
