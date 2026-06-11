return {
	["image"] = function(raw_args)
		img_path = raw_args[1]
		img_width = raw_args[2] -- Only for PDF
		img_height = raw_args[3] -- Only for PDF
		img_alt = raw_args[4]

		if quarto.doc.is_format("pdf") then
			block = pandoc.RawBlock(
				"tex",
				"\\includegraphics[width="
					.. img_width
					.. "pt, height="
					.. img_height
					.. "pt, alt ="
					.. img_alt
					.. "]{"
					.. img_path
					.. "}"
			)
		end

		if quarto.doc.is_format("revealjs") then
			block = pandoc.RawBlock("html", '<img src="' .. img_path .. '" class="fragment" alt="' .. img_alt .. '">')
		end

		if quarto.doc.is_format("html") then
			block = pandoc.RawBlock("html", '<img src="' .. img_path .. '" class="fragment" alt="' .. img_alt .. '">')
		end

		return block
	end,
}
