<?xml version="1.0" encoding="UTF-8"?>
<sch:schema xmlns:sch="http://purl.oclc.org/dsdl/schematron" queryBinding="xslt2"
    xmlns:sqf="http://www.schematron-quickfix.com/validator/process">
    <sch:ns uri="http://www.loc.gov/MARC21/slim" prefix="marc"/>
    <sch:pattern>
        
        <sch:rule context="marc:record">
            <sch:let name="name" value="marc:datafield[@tag='035']/marc:subfield[@code='a']"/>
            <sch:let name="title" value="marc:datafield[@tag='245' and string(marc:subfield[@code='a'])]/marc:subfield[@code='a']"/>
            <sch:assert test="marc:datafield[@tag='920' and string(marc:subfield[@code='a']) and marc:subfield[@code='b'] and (every $x in marc:subfield[@code='b'] satisfies string($x))]"><sch:value-of select="concat($name,': ',$title)"/> Record does not have a category in 920 with subfield string(a) and strings(b).</sch:assert>
            <sch:assert test="marc:datafield[@tag='922' and string(marc:subfield[@code='a'])]"><sch:value-of select="concat($name,': ',$title)"/> Record does not have a description in 922 with subfield a</sch:assert> 
            <sch:assert test="marc:datafield[@tag='922' and string(marc:subfield[@code='a'])]"><sch:value-of select="concat($name,': ',$title)"/> Record does not have a description in 922 with subfield a</sch:assert>
            <sch:assert test="marc:datafield[@tag='956' and matches(marc:subfield[@code='u'],'^http')]"><sch:value-of select="concat($name,': ',$title)"/> Record does not have a url in 956u with regex ^http</sch:assert>
            <sch:assert test="$title"><sch:value-of select="concat($name,': ',$title)"/> Record does not have a title</sch:assert>
        </sch:rule>
       
        
        
    </sch:pattern>
    <sch:pattern ></sch:pattern>
</sch:schema>