<?xml version="1.0" encoding="UTF-8"?>
<sch:schema xmlns:sch="http://purl.oclc.org/dsdl/schematron" queryBinding="xslt2"
    xmlns:sqf="http://www.schematron-quickfix.com/validator/process">
    <sch:pattern>
        <sch:p></sch:p>
        <sch:rule context="*">
            <sch:assert test="string(.)"><sch:value-of select="name()"/> Item does not have a string!</sch:assert>
            <sch:report test="string(.)"><sch:value-of select="name()"/> Item does have a string!</sch:report>
        </sch:rule>
        
    </sch:pattern>
    <sch:pattern ></sch:pattern>
</sch:schema>