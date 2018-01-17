<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:marcx="http://www.loc.gov/standards/marcxml/schema/MARC21slim.xsd"
    xmlns:flub="http://data.ub.uib.no/xsl/function-library"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:marc="http://www.loc.gov/MARC21/slim" xmlns="http://www.loc.gov/MARC21/slim"
    exclude-result-prefixes="xs flub xsi marcx marc" version="2.0">
    <xsl:strip-space elements="*"/>
    <!-- example posts atekst, -wos-, jstor, lovdata, -pubmed- ('UNI08537','UNI01563','UNI03671','UNI19590','UNI01300')-->
    <xsl:param name="examples" as="xs:string*" select="(::('UNI08537','UNI01563','UNI03671','UNI19590','UNI01300')::)()"/>
    <xsl:param name="except" as="xs:string*" select="(::('UNI08537','UNI01563','UNI03671','UNI19590','UNI01300')::)()"/>
    <xsl:param name="proxy" as="xs:string?"/>
    <xsl:param name="id-list" as="xs:boolean" select="true()"/>
    <xsl:output indent="yes" method="xml"/>
    <!-- stylesheet to transform from metalib dump to normarc import for bibsys consortium-->
    <xsl:param name="institution" select="'UBB'" as="xs:string"/>
    <xsl:param name="languages" select="'en'"/>
    
    <xsl:output method="xml" indent="yes" encoding="UTF-8"/>
    <xsl:variable name="controlfield_003">
        <controlfield tag="003">IL-JeEL</controlfield>    
    </xsl:variable>
   
    
    <xsl:variable name="controlfield_008" as="element(marc:controlfield)">
        <xsl:variable name="_008" as="element(marc:controlfield)">

            <marc:controlfield tag="008">########################################</marc:controlfield>
        </xsl:variable>
        <xsl:sequence
            select="
            flub:replaceFieldInPosition(
            flub:replaceFieldInPosition(
            flub:replaceFieldInPosition(
            flub:replaceFieldInPosition(
            flub:replaceFieldInPosition(
            flub:replaceFieldInPosition(
            flub:replaceFieldInPosition(
            flub:replaceFieldInPosition(
            flub:replaceFieldInPosition(
            flub:replaceFieldInPosition(
            flub:replaceFieldInPosition($_008
            ,6,'c')
            ,11,'9999')
            ,15,'xx')
            ,18,'k')
            ,19,'|')            
            ,21,'d')
            ,23,'o')
            ,28,'||')
            ,34, '2')
            ,38,'|')
            ,39,'c')"
        />
    </xsl:variable>
    
    <xsl:variable name="datafield_040" as="element(marc:datafield)">
        <datafield tag="040" ind1=" " ind2=" ">
            <subfield code="a">NO-TrBIB</subfield>
            <subfield code="b">nob</subfield>
            <subfield code="e">katreg</subfield>
        </datafield>
    </xsl:variable>
    
    <xsl:variable name="multilang-regex" select="'#{2,} *#{2,}'"/>
    <xsl:key name="category-by-id" match="*" use="@id"/>
    
    <xsl:template match="*:datafield[@tag='653' and preceding-sibling::*:datafield[@tag='653']]" priority="2.4" mode="strip-groups"/>
    <xsl:template match="*:datafield[@tag='653' and not(preceding-sibling::*:datafield[@tag='653'])]" priority="2.4" mode="strip-groups">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
        <xsl:for-each select="(*:subfield[@code='a'],following-sibling::*:datafield[@tag='653']/*:subfield[@code='a'])">
            <xsl:copy>
                <xsl:copy-of select="@*"/>
                <xsl:apply-templates mode="#current"/>
            </xsl:copy>
        </xsl:for-each>
        </xsl:copy>      
    </xsl:template>
    
    <xsl:template match="*:file" priority="1.0">
        <xsl:variable name="categories" select="document('categories.xml')"/>    
        <xsl:variable name="result"><collection xmlns="http://www.loc.gov/MARC21/slim">
            <xsl:apply-templates>
                <xsl:with-param name="categories" tunnel="yes" select="$categories"/>
            </xsl:apply-templates>
        </collection>
        </xsl:variable>
        <xsl:apply-templates select="$result" mode="strip-groups"/>
        
        <xsl:if test="$id-list">
        <xsl:result-document href="id.txt" encoding="utf-8" method="text">
            <xsl:for-each select="$result/descendant-or-self::*:record/*:datafield[@tag='035']/*:subfield[@code='a']">
                <xsl:value-of select="."/>
                <xsl:if test="parent::*/following-sibling::*[1]">
                    <xsl:text>
</xsl:text>
                </xsl:if>
            </xsl:for-each>           
        </xsl:result-document>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="*" priority="0.5">
        <xsl:apply-templates/>
    </xsl:template>    
    
    <!-- explicitly just selecting record children-->
    <xsl:template match="*:knowledge_unit" priority="2.0">
        <xsl:variable name="_001" select="*:record/*:controlfield[@tag='001']"/>
        <xsl:if test="($_001=$examples or count($examples) =0)
            and not(some $x in $except satisfies $x = $_001)">     
           <xsl:apply-templates select="*:record"/>
        </xsl:if>
    </xsl:template>
    
    

    <xsl:template match="text()" mode="copy sort">
        <xsl:value-of select="."/>
    </xsl:template>
    
    <!-- ignore text match with with no mode-->
    <xsl:template match="text()"/>

    <xsl:template match="*" mode="copy sort strip-groups" priority="2.0">
        <xsl:element name="{local-name()}">
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates mode="#current"/>
            <xsl:if test="self::*:datafield">
                <xsl:sequence select="flub:addLocal(self::*:datafield)"/>
            </xsl:if>
        </xsl:element>
    </xsl:template>

    <!-- Removed because of unused fields in marc. Should some of these be remapped?
         Github issues.
    -->

    <xsl:template
        match="
            *:datafield[@tag = ('531', '532', '574',
            '575', '591', '592', '593', '594', '595', '901', '902', '956') and *:subfield/@code = 'a'] |
            *:datafield[@tag = '856']/*:subfield[@code = ('7', 'D')] |
            *:datafield[@tag = '245']/*:subfield[@code = '9'] |
            *:datafield[@tag='856' and *:subfield[@code='u']='$856_u']"
        priority="2.1" mode="copy #default"/>
    <!--
MARC 09x, 59x, 69x, and 950-999 local fields-->
    <xsl:template
        match="*:datafield[matches(@tag, '^[0-9]+')] | *:controlfield[matches(@tag, '^[0-9]+')]"
        priority="1.8">
        <xsl:param name="OA" as="xs:boolean" select="false()" tunnel="yes"/>
        
        <xsl:element name="{local-name()}">
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates mode="copy"/>
        <xsl:if test="@tag='856' and $OA">
            <subfield code="z">Gratis</subfield>
        </xsl:if>
        </xsl:element>
    </xsl:template>
    <!-- change ind1 of titles-->
    <xsl:template match="*:datafield[@tag = '246' or @tag='210']" priority="2.3">
   
        <xsl:if
            test="*:subfield[@code = 'a'] != parent::*/*:datafield[@tag = '245']/*:subfield[@code = 'a']">
            <xsl:element name="{local-name()}">
                <!-- change 210 also to 246 if it is different from 245-->
                <xsl:attribute name="tag" select="'246'"/>
                <xsl:attribute name="ind1" select="0"/>
                <xsl:copy-of select="@* except (@tag, @ind1)"/>
                <xsl:apply-templates mode="copy"/>
            </xsl:element>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match=" *:datafield[@tag = '260' and (*:subfield/@code = 'a' or *:subfield/@code = 'b')]"
        priority="2.1" mode="copy">      
        <xsl:element name="{local-name()}">
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates mode="copy"/>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="*:datafield[@tag = '245' and *:subfield/@code = 'a']"
        priority="2.1" mode="copy">      
        <xsl:element name="{local-name()}">
            <xsl:copy-of select="@*"/>
            <!-- override ind2-->
            <xsl:attribute name="ind2" select="'0'"/>
            <xsl:apply-templates mode="copy"/>
            <marc:subfield code="h">[elektronisk ressurs]</marc:subfield>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="*:datafield[@tag='655']" priority="4.0">
        <marc:datafield tag="653" ind1=" " ind2=" " >
            <xsl:for-each select="*:subfield">
                <marc:subfield>
                    <xsl:copy-of select="@*"/>
                    <xsl:value-of select="."/>
                </marc:subfield>
               
            </xsl:for-each><xsl:apply-templates/>
        </marc:datafield>
    </xsl:template>
    
    <xsl:template match="*:datafield[@tag='110']" priority="4.0">
      
        <xsl:if test="not(parent::*/*:datafield[@tag='260'])">
        <marc:datafield ind1=" " ind2=" " tag="260">
            <subfield code="b"><xsl:value-of select="*:subfield[@code='a']"/></subfield>
        </marc:datafield>
        </xsl:if>
    </xsl:template>
    
                         
    <xsl:template match="*:datafield[@tag='520']" priority="4.0">       
        <xsl:variable name="multilang" select="flub:isBiLingual(*:subfield[@code='a'])"/>
      
        <xsl:element name="{local-name()}">
            <xsl:attribute name="tag" select="'922'"/>
            <xsl:copy-of select="@* except @tag"/>
            <xsl:choose>
                <xsl:when test="$multilang">
                    <xsl:apply-templates mode="parse">
                        <xsl:with-param name="position" select="2"/>
                    </xsl:apply-templates>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates mode="parse">
                        <xsl:with-param name="position" select="1"/>
                    </xsl:apply-templates>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:element>
        
    </xsl:template>
    
    <xsl:template match=" *:datafield[@tag = '520']/*:subfield[@code='a']" mode="parse">
        <xsl:param name="position" as="xs:integer?"/>        
        <xsl:element name="{local-name()}">
            <xsl:copy-of select="@*"/>
            <xsl:value-of select="flub:parseMetalibURL(tokenize(.,$multilang-regex)[($position,1)[1]])"/>                   
        </xsl:element>
        <xsl:call-template name="subfield_code_5"/>
        <!--importerer ikkje lang<subfield code="9"><xsl:value-of select="if ($position=1) then 'nor' else 'eng'"/></subfield>-->
    </xsl:template>
    
    <xsl:template name="controlfield_008">
        <xsl:sequence
            select="
                flub:replaceFieldInPosition(
                flub:replaceFieldInPosition(
                flub:replaceFieldInPosition(
                flub:replaceFieldInPosition($controlfield_008
                , 18, 'k')
                , 21, 'd')
                , 23, 'o')
                , 34, '2')"
        />
    </xsl:template>

    <!-- Our metalib contains many inactive items. Only use records with: 
        <datafield tag="STA" ind1=" " ind2=" ">
    <subfield code="a">ACTIVE</subfield>
  </datafield>
    -->
    <xsl:template match="*:record[*:datafield[@tag = 'STA']/*:subfield[@code = 'a'] = 'ACTIVE']"
        priority="1.0">
        <xsl:variable name="record-element">
            <xsl:element name="{local-name()}">
                <xsl:copy-of select="@*" copy-namespaces="no"/>
                <xsl:sequence select="$leader"/>
                <xsl:sequence select="$controlfield_003"/>
                <xsl:call-template name="controlfield_005"/>
                <xsl:sequence select="$controlfield_007"/>
                <xsl:call-template name="controlfield_008"/>

                <xsl:variable name="conditionForOA" as="xs:boolean">
                    <xsl:sequence
                        select="
                            if (*:datafield[@tag = '594']/*:subfield[@code = 'a'
                            and matches(., 'FREE', 'i')]
                            )
                            then
                                true()
                            else
                                false()"
                    />
                </xsl:variable>

                <xsl:apply-templates>
                    <xsl:with-param name="OA" select="$conditionForOA" tunnel="yes"/>
                </xsl:apply-templates>

                <xsl:call-template name="datafield_035"/>
                <xsl:sequence select="$datafield_040"/>
                <!-- apply category from outside of record. Only go to first of each main category, 
            to nest the categories -->
                <xsl:apply-templates
                    select="parent::*:knowledge_unit/*:category/(*:main except *:main[preceding-sibling::*:main = .])"
                    mode="datafield_920"/>

                <xsl:if test="$conditionForOA">
                    <datafield tag="999" ind1=" " ind2=" ">
                        <subfield code="a">OA</subfield>
                    </datafield>
                </xsl:if>
            </xsl:element>
        </xsl:variable>
        <!-- sorting records based on tag, ind1 and ind2-->
        <record>
            <xsl:apply-templates mode="sort" select="$record-element/descendant-or-self::*:record/*">
                <xsl:sort select="@tag"/>
                <xsl:sort select="@ind1"/>
                <xsl:sort select="@ind2"/>
            </xsl:apply-templates>
        </record>        
     
    </xsl:template>
    
    
    
    <xsl:template match="*:datafield"/>

    <xsl:template
        match="*:datafield[@tag = '856' and @ind1 = '4' and (@ind2 = '1' or @ind2 = '9') and *:subfield/@code = 'u']"
        priority="2.5">
        <xsl:param name="OA" tunnel="yes" as="xs:boolean" select="false()"/>
        <xsl:if test="@ind2='1'">
            <datafield tag="856" ind1="4" ind2="0">
            <subfield code="3">Fulltekst</subfield>
            <subfield code="u"><xsl:value-of select="*:subfield[@code = 'u']"/></subfield>
            <xsl:if test="$OA">
                    <subfield code="z">Gratis</subfield>
            </xsl:if>
            </datafield>
        </xsl:if>
        <datafield tag="{if (@ind2='9') then 921
                else 956}" ind1=" " ind2=" ">
           <!-- use url if OA, not main link-->
           <xsl:variable name="resource-url" select="if ((($OA) or(@ind2='9') or not($proxy)))
               then *:subfield[@code = 'u'] 
               else concat($proxy,*:subfield[@code = 'u']) "/>            
            <subfield code="u">
                <xsl:value-of select="$resource-url"/>
            </subfield>
            <xsl:call-template name="subfield_code_5"/>
        </datafield>
    </xsl:template>

    <xsl:template mode="datafield_920" match="*:category/*:main">
        <xsl:param name="categories" tunnel="yes" as="node()"/>
        <xsl:variable name="this_context" select="."/>
        <xsl:for-each select="tokenize($languages, '\s')">
            <xsl:if test="position() > 1">
                <xsl:message terminate="yes">
                    No handling of multiple lang tags in import. $9 reserver for local Choose one language for import.</xsl:message>
            </xsl:if>
            <xsl:variable name="lang" select="."/>
                <xsl:variable name="current-cat"
                    select="key('category-by-id', $this_context, $categories)"/>
                <xsl:if test="not($current-cat/(@* except @id))">
                    <xsl:message terminate="yes">Finner inngen språk attributter for <xsl:value-of
                            select="$this_context"/> Opprett 'en' eller 'nb' translations i
                            <xsl:value-of select="base-uri($categories)"/></xsl:message>
                </xsl:if>                
                <xsl:variable name="sub-context" select="$this_context/following-sibling::*[1]"/>
                <xsl:for-each
                    select="$this_context/following-sibling::*:sub[preceding-sibling::*[1]/text() = $this_context]">
                    <xsl:variable name="sub-cat"
                        select="key('category-by-id', ., $current-cat)/@*[name() = $lang]"/>
                    <datafield tag="920" ind1=" " ind2=" ">
                        <subfield code="a">
                            <xsl:value-of select="$current-cat/@*[name() = $lang]"/>
                        </subfield>    
                    <subfield code="b">
                        <xsl:value-of select="$sub-cat"/>
                    </subfield>
                    <xsl:call-template name="subfield_code_5"/>
                    </datafield>
                </xsl:for-each>
                
        </xsl:for-each>
    </xsl:template>

    <!-- remove all datafields which are not covered by the general rule-->
    <xsl:template match="*:datafield" priority="0.7"/>

    <!-- remove all records which are not ACTIVE-->
    <xsl:template match="*:record" priority="0.7"/>

    <xsl:template name="subfield_code_5">
        <subfield code="5">
            <xsl:value-of select="$institution"/>
        </subfield>
    </xsl:template>

    <xsl:template name="controlfield_005">
        <controlfield tag="005">
            <xsl:value-of
                select="format-dateTime(adjust-dateTime-to-timezone(current-dateTime(), xs:dayTimeDuration('PT0H')), '[Y][M01][D01][H01][m01][s01].0')"
            />
        </controlfield>
    </xsl:template>
    
    <xsl:variable name="controlfield_007" as="element(marc:controlfield)">
        <marc:controlfield tag="007">cr#||||||</marc:controlfield> 
    </xsl:variable>
    
    <xsl:template name="datafield_035">
        <datafield tag="035" ind1=" " ind2=" ">
            <subfield code="a">
                <xsl:sequence
                    select="concat('(', $controlfield_003, ')', *:controlfield[@tag = '001'])"/>
            </subfield>
        </datafield>
    </xsl:template>

    <xsl:variable name="leader" as="element(marc:leader)">        
        <marc:leader>     cai a22000005c 4500</marc:leader>
    </xsl:variable>
    
    <xsl:function name="flub:replaceFieldInPosition" as="element(marc:controlfield)">
        <xsl:param name="controlfield" as="element(marc:controlfield)"/>
        <xsl:param name="position" as="xs:integer"/>
        <xsl:param name="insert_value" as="xs:string"/>
        <!-- to replace sibling values we use the length of the insert value-->
        <xsl:variable name="length" select="string-length($insert_value)"/>
        <xsl:if test="not($controlfield/local-name() = 'controlfield')">
            <xsl:message terminate="yes"> flub:replaceFieldInPosition: not controlfield
            </xsl:message>
        </xsl:if>
        <!-- 008 first index position is 00, so starting position is -->
        <xsl:variable name="marc-position" select="$position"/>
        <xsl:variable name="regexp"
            select="concat('^([\s\S]{', $marc-position, '})[\s\S]{', $length, '}')"/>
        <xsl:variable name="controlfield_out" as="element(marc:controlfield)">
            <xsl:for-each select="$controlfield">
               <xsl:copy>
                    <xsl:copy-of select="@*"/>
                    <xsl:value-of select="replace(., $regexp, concat('$1', $insert_value))"/>
               </xsl:copy>             
            </xsl:for-each>
        </xsl:variable>

        <xsl:if test="$position &lt; 0 or $position &gt; string-length($controlfield)">
            <xsl:message terminate="yes">flub:replaceFieldInPosition $position <xsl:value-of
                    select="$position"/> out of bounds. </xsl:message>
        </xsl:if>

        <xsl:if test="string-length($controlfield) != string-length($controlfield_out)">
            <xsl:message terminate="yes"> flub:replaceFieldInPosition(): controlfield out of bounds.
            </xsl:message>
        </xsl:if>
        <xsl:copy-of select="$controlfield_out"/>

    </xsl:function>

    <!-- MARC 09x, 59x, 69x, and 950-999 r-->
    <xsl:function name="flub:addLocal">
        <xsl:param name="datafield" as="element(marc:datafield)"/>
        <xsl:if
            test="$datafield/self::*:datafield and matches($datafield/@tag, '^(09|69|9)') and not($datafield/*:subfield[@code = '9' and . = 'local'])">
            <subfield code="9">local</subfield>
        </xsl:if>
    </xsl:function>
    
    <xsl:function name="flub:isBiLingual" as="xs:boolean">
        <xsl:param name="subfield" as="element(marcx:subfield)"/>
        <xsl:sequence select="if (count(tokenize($subfield[@code='a'],$multilang-regex))=2)
            then true()
            else false()"/>
    </xsl:function>
    
    <xsl:function name="flub:parseMetalibURL">
        <xsl:param name="locale-string" as="xs:string"/>
        <xsl:analyze-string select="$locale-string" regex="@@U([^@]+)@@D([^@]+)@@E">
            <xsl:matching-substring>
                <xsl:value-of select="concat(normalize-space(regex-group(2)),' (',normalize-space(regex-group(1)),')')"/>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <xsl:value-of select="."/>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:function>
</xsl:stylesheet>