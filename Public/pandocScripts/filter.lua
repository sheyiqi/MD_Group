-- pagebreak.lua
-- 将 <!-- pagebreak -->, \newpage 和 \pagebreak 转换为 Word 分页符
--
--function RawBlock(el)
--    -- 处理 <!-- pagebreak -->
--    if el.text == '<!-- pagebreak -->' then
--        return pandoc.RawBlock('openxml', '<w:p><w:r><w:br w:type="page"/></w:r></w:p>')
--    end
--    
--    -- 处理 \newpage 和 \pagebreak
--    if el.text == '\\newpage' or el.text == '\\pagebreak' then
--        return pandoc.RawBlock('openxml', '<w:p><w:r><w:br w:type="page"/></w:r></w:p>')
--    end
--end
--
--function Div(el)
--    -- 处理 ::: pagebreak 这样的 div 语法
--    if el.attr and el.attr.classes:includes('pagebreak') then
--        return pandoc.RawBlock('openxml', '<w:p><w:r><w:br w:type="page"/></w:r></w:p>')
--    end
--end
--
--local stringify = pandoc.utils.stringify
--
--function Pandoc(doc)
--    -- 查找文档中特定的标记位置
--    local blocks = {}
--    local toc_inserted = false
--    local toc_marker = "{{TOC}}"
--
--    for i, el in pairs(doc.blocks) do
--        if el.t == "Para" then
--        local content = stringify(el)
--        if content == toc_marker then
--            table.insert(blocks, pandoc.RawBlock('openxml', 
--            [[<w:sdt>
--                <w:sdtPr>
--                <w:docPartObj>
--                    <w:docPartGallery w:val="Table of Contents"/>
--                    <w:docPartUnique/>
--                </w:docPartObj>
--                </w:sdtPr>
--                <w:sdtContent>
--                <w:p>
--                    <w:pPr>
--                    <w:pStyle w:val="TOC"/>
--                    </w:pPr>
--                    <w:r>
--                    <w:rPr>
--                        <w:rFonts w:hint="eastAsia"/>
--                    </w:rPr>
--                    <w:t xml:space="preserve">目录</w:t>
--                    </w:r>
--                </w:p>
--                <w:p>
--                    <w:r>
--                    <w:fldChar w:fldCharType="begin" w:dirty="true"/>
--                    <w:instrText xml:space="preserve">TOC \o "1-4" \h \z \u</w:instrText>
--                    <w:fldChar w:fldCharType="separate"/>
--                    <w:fldChar w:fldCharType="end"/>
--                    </w:r>
--                </w:p>
--                </w:sdtContent>
--            </w:sdt>]]))
--            toc_inserted = true
--        else
--            table.insert(blocks, el)
--        end
--        else
--        table.insert(blocks, el)
--        end
--    end
--
--    return pandoc.Pandoc(blocks, doc.meta)
--end
--
--function CodeBlock(block)
--    if block.text:match '^!include ' then
--      local filename = block.text:match '^!include (%S+)'
--      return pandoc.read(io.open(filename):read('*a'), 'markdown').blocks
--    end
--  end
--
--
--function BlockQuote(el)
--  for i, block in ipairs(el.content) do
--    if block.t == "Para" or block.t == "Plain" then
--      -- 创建一个全新的 Para 块，内容不变，但 attr 里配上 custom-style
--      local new_attr = pandoc.Attr("", {}, {["custom-style"] = "myquote2"})
--      local new_block
--      if block.t == "Para" then
--        new_block = pandoc.Para(block.content, new_attr)
--      else
--        -- Plain 转成 Para，避免样式丢失
--        new_block = pandoc.Para(block.content, new_attr)
--      end
--      -- 用新块替换旧块
--      el.content[i] = new_block
--    end
--  end
--  return el
--end


-- 这是 dynamic-header.lua 文件的全部内容

---- ==========================================
---- 功能一：阻止编号传递 (解决非标准编号/空行导致编号后缀传递的问题)
---- ==========================================
--function Header(el)
--  -- 把标题的内容转成纯文本字符串  
--  local txt = pandoc.utils.stringify(el.content)
--  -- 删除末尾的 {#...} (如果存在)
--  txt = string.gsub(txt, "%s*{%#.-%}$", "")
--  -- 重新生成一个干净的标题（不带ID、不带属性），这会打破Word中的编号链
--  return pandoc.Header(el.level, pandoc.Str(txt))
--end
--
---- ==========================================
---- 功能二：设置当前章节标题
---- ==========================================
--local current_chapter = "目录"
--
--function Header(el)
--    -- 选择作为页眉的标题层级, 这里以 1 级 和 2 级标题为例
--    if el.level == 1 or el.level == 2 then
--        -- 将标题文本转换为普通字符串，并存入全局变量
--        current_chapter = pandoc.utils.stringify(el.content)
--        -- 将当前章节名存储到文档的元数据中，供其他部分读取
--        -- 这里我们将它存入一个名为 "current-chapter" 的元数据变量
--        quarto.doc.add_metadata({
--            ["current-chapter"] = current_chapter
--        })
--    end
--    -- 返回 nil 表示不对标题本身做额外修改
--    return nil
--end
--
---- 为了让 "目录" 页也能显示正确页眉，初始化变量
--return {
--    {
--        Meta = function(meta)
--            -- 如果文档元数据中没有 current-chapter 字段，则初始化为 "目录"
--            if not meta["current-chapter"] then
--                meta["current-chapter"] = pandoc.MetaInlines(pandoc.Str("目录"))
--            end
--            return meta
--        end
--    }
--}

function Image(img)
  -- 强制固定宽度 10cm（或 80%）
  img.attributes.width = "80%"
  -- 去掉可能冲突的 height
  img.attributes.height = nil
  return img
end

--function Strong(elem)
--  return pandoc.Span(elem.content, {["custom-style"] = "Table Highlight"})
--end


--[[
  section-break.lua
  功能：将 Markdown 中带有 section-break 类的 Div 转换为 Word 分节符（下一页）。
  使用：pandoc input.md --lua-filter=section-break.lua -o output.docx
]]



--[[
  section-break-page-setup.lua
  在插入分节符的同时，为**前一节**（如目录节）设置页边距和纸张大小。
]]

function Div(el)
  if el.classes:includes('section-break') then
    -- 页边距（单位 twips，1 cm ≈ 567 twips）
    local top    = 850  -- 上  2.54 cm
    local bottom = 850  -- 下  2.54 cm
    local left   = 850  -- 左  约 3.17 cm
    local right  = 850  -- 右  约 3.17 cm

    -- 纸张大小：A4 标准尺寸（单位 twips，1 twip = 1/1440 英寸）
    local pageWidth  = 11906   -- A4 宽 210 mm
    local pageHeight = 16838   -- A4 高 297 mm

    -- 其他常见尺寸备查：
    -- A3: 16838 × 23814
    -- B5: 10063 × 14208
    -- 16开: 10942 × 15458

    -- 构造带分节符的段落
    local sectBreakXml = string.format([[
      <w:p>
        <w:r>
          <w:br w:type="page" />
        </w:r>
      </w:p>
      <w:p>
        <w:pPr>
          <w:sectPr>
            <w:pgSz w:w="%d" w:h="%d" w:orient="portrait" />
            <w:pgMar w:top="%d" w:bottom="%d" w:left="%d" w:right="%d"
                     w:header="720" w:footer="720" w:gutter="0" />
            <w:type w:val="nextPage" />
          </w:sectPr>
        </w:pPr>
      </w:p>
    ]], pageWidth, pageHeight, top, bottom, left, right)

    return pandoc.RawBlock('openxml', sectBreakXml)
  end
end