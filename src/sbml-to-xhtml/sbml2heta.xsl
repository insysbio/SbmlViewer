<?xml version="1.0" encoding="UTF-8"?>
<!--
Copyright 2016-2021 InSysBio, LLC

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
-->
<!-- INFO
Description: Creating representation of whole sbml into Heta format.
Source files: SBML L2 V1-5
TODO:
  * all components: unitDefinition, functionDefinition, initialAssignment, rate, event
  * add properties from sbml, model, listOf as comments

Author: Evgeny Metelkin
Project-page: https://sv.insysbio.com, https://hetalang.insysbio.com
-->
<xsl:stylesheet version="1.0"
  xmlns="http://www.w3.org/1999/xhtml"
  xmlns:xhtml="http://www.w3.org/1999/xhtml"
  xmlns:l2v1="http://www.sbml.org/sbml/level2"
  xmlns:l2v2="http://www.sbml.org/sbml/level2/version2"
  xmlns:l2v3="http://www.sbml.org/sbml/level2/version3"
  xmlns:l2v4="http://www.sbml.org/sbml/level2/version4"
  xmlns:l2v5="http://www.sbml.org/sbml/level2/version5"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:mml="http://www.w3.org/1998/Math/MathML"
  exclude-result-prefixes="mml xhtml l2v1 l2v2 l2v3 l2v4 l2v5">

  <xsl:output encoding="UTF-8" indent="no"/>

  <!-- GLOBAL KEYS -->
  <xsl:key name="idKey" match="*" use="@id"/>
  <xsl:key name="variableKey" match="*" use="@variable"/>

  <!-- PARAMETERS -->
  <xsl:param name="fullForm">false</xsl:param> <!-- do not display aux -->

<!-- BEGIN nothing -->
  <xsl:template match="*">
    <span class="heta-debug">{ no transformation for: <xsl:value-of select="local-name()"/> }</span>
  </xsl:template>

  <xsl:template match="text()">
    <span class="heta-debug">{ no transformation for text: <xsl:value-of select="."/> }</span>
  </xsl:template>

  <xsl:template match="attribute::*">
    <span class="heta-debug">{ no transformation for attribute: <xsl:value-of select="local-name()"/> }</span>
  </xsl:template>
<!-- END nothing -->

  <!-- top -->
  <xsl:template match="/">
    <xsl:apply-templates mode="heta"/>
  </xsl:template>

  <!-- SBML -->
  <xsl:template match="*[local-name()='sbml']" mode="heta">
    <div class="sv-container sv-mode-heta">
      <h3 class="sv-header">Transformation from SBML level <xsl:value-of select="@level"/> version <xsl:value-of select="@version"/> to Heta code</h3>
      <h4 class="sv-header">More info about Heta format can be found in <a href="https://hetalang.github.io" target="blank_">https://hetalang.github.io</a></h4>
      <div class="sv-content heta-code">
        <!--<xsl:apply-templates select="*[local-name()='notes']" mode="element"/>
        <xsl:apply-templates select="*[local-name()='annotation']" mode="element"/>-->
        <xsl:apply-templates select="*[local-name()='model']" mode="heta"/>
      </div>
    </div>
  </xsl:template>

  <!-- model -->
  <xsl:template match="*[local-name()='model']" mode="heta">
    <pre>
      <!--<xsl:apply-templates select="*[local-name()='notes']" mode="element"/>
      <xsl:apply-templates select="*[local-name()='annotation']" mode="element"/>-->
      <xsl:apply-templates select="*[contains(local-name(), 'listOf')]" mode="heta"/>
    </pre>
  </xsl:template>

  <!-- notes -->
  <xsl:template match="*[local-name()='notes']" mode="heta-sugar">
    <span class="heta-notes">'''<xsl:apply-templates select="*"/>'''
</span>
  </xsl:template>

  <!-- this is for notes without xhtml -->
  <xsl:template match="*[local-name()='notes' and not(xhtml:*) and text()]" mode="heta-sugar">
    <span class="heta-notes">'''<xsl:value-of select="normalize-space(text())"/>'''
</span>
  </xsl:template>

  <!-- id -->
  <xsl:template match="@id" mode="heta-sugar">
    <span class="heta-id"><xsl:value-of select="."/></span>
  </xsl:template>

  <!-- name -->
  <xsl:template match="@name" mode="heta-sugar">
    <span class="heta-title"> '<xsl:value-of select="."/>'</span>
  </xsl:template>

<!-- BEGIN listOf -->
  <!-- unsupported listOf... -->
  <xsl:template 
    match="*[contains(local-name(), 'listOf')]"
    mode="heta"
    >
    <span class="heta-block">
      <span class="heta-comment">
// = <xsl:value-of select="local-name()"/> =</span>
      <span class="heta-comment">
/* not supported in current version */
</span>
    </span>
  </xsl:template>

  <!-- listOfCompartments -->
  <xsl:template 
    match="*[local-name()='listOfCompartments']"
    mode="heta"
    >
    <span class="heta-block">
      <span class="heta-comment">
// = listOfCompartments =
</span>
      <xsl:apply-templates select="*[local-name()='compartment']" mode="heta"/>
    </span>
  </xsl:template>

  <!-- listOfSpecies -->
  <xsl:template 
    match="*[local-name()='listOfSpecies']"
    mode="heta"
    >
    <span class="heta-block">
      <span class="heta-comment">
// = listOfSpecies =
</span>
      <xsl:apply-templates select="*[local-name()='species']" mode="heta"/>
    </span>
  </xsl:template>

  <!-- listOfParameters -->
  <xsl:template 
    match="*[local-name()='listOfParameters']" 
    mode="heta"
    >
    <span class="heta-block">
      <span class="heta-comment">
// = listOfParameters =
</span>
      <xsl:apply-templates select="*[local-name()='parameter']" mode="heta"/>
    </span>
  </xsl:template>

  <!-- listOfReactions -->
  <xsl:template 
    match="*[local-name()='listOfReactions']" 
    mode="heta"
    >
    <span class="heta-block">
      <span class="heta-comment">
// = listOfReactions =
</span>
      <xsl:apply-templates select="*[local-name()='reaction']" mode="heta"/>
    </span>
  </xsl:template>

<!-- END listOf -->

<!-- BEGIN components -->

  <xsl:template 
    match="
      *[local-name()='compartment']
      |*[local-name()='species']
      |*[local-name()='parameter']
    "
    mode="heta"
    >
    <xsl:text>
</xsl:text>
    <xsl:apply-templates select="." mode="heta-sugar"/>
    <xsl:apply-templates select="." mode="heta-assignment"/>
    <!--
    <xsl:apply-templates select="@compartmentType"/>
    <xsl:apply-templates select="./*[local-name()='annotation']" mode="element"/>
    -->
  </xsl:template>

  <xsl:template 
    match="*[local-name()='reaction']" 
    mode="heta"
    >
    <xsl:text>
</xsl:text>
    <xsl:apply-templates select="." mode="heta-sugar"/>
    <xsl:apply-templates select="." mode="heta-assignments-ode"/>
  </xsl:template>

  <xsl:template 
    match="*" 
    mode="heta-sugar"
    >
    <span class="heta-base">
      <xsl:apply-templates select="./*[local-name()='notes']" mode="heta-sugar"/>
      <xsl:apply-templates select="@id" mode="heta-sugar"/>
      <xsl:apply-templates select="." mode="heta-class"/>
      <xsl:apply-templates select="@name" mode="heta-sugar"/>
      <xsl:apply-templates select="." mode="heta-dict"/>
      <span class="heta-end">;
</span>
    </span>
  </xsl:template>

  <xsl:template match="*[local-name()='compartment']" mode="heta-class">
    <span class="heta-class"> @Compartment</span>
  </xsl:template>

  <xsl:template match="*[local-name()='species']" mode="heta-class">
    <span class="heta-class"> @Species</span>
  </xsl:template>

  <xsl:template match="*[local-name()='parameter']" mode="heta-class">
    <span class="heta-class"> @Record</span>
  </xsl:template>

  <xsl:template match="*[local-name()='parameter' and @constant='true']" mode="heta-class">
    <span class="heta-class"> @Const</span>
  </xsl:template>

  <xsl:template match="*[local-name()='reaction']" mode="heta-class">
    <span class="heta-class"> @Reaction</span>
  </xsl:template>

<!-- END components -->

<!-- BEGIN assignments -->

  <!-- no value -->
  <xsl:template
    match="*"
    mode="heta-assignment"
    >
  </xsl:template>

  <xsl:template
    match="*[local-name()='compartment' and @size]"
    mode="heta-assignment"
    >
    <span>
      <xsl:apply-templates select="@id" mode="heta-sugar"/>
      <span class="heta-assignments"> .= </span>
      <span class="heta-string heta-math-expr"> <xsl:value-of select="@size"/></span>
      <span class="heta-end">;
</span>
    </span>
  </xsl:template>

  <xsl:template
    match="*[local-name()='species' and @initialConcentration and not(@hasOnlySubstanceUnits='true' or key('idKey',@compartment)/@spatialDimensions='0')]"
    mode="heta-assignment"
    >
    <span>
      <xsl:apply-templates select="@id" mode="heta-sugar"/>
      <span class="heta-assignments"> .= </span>
      <span class="heta-string heta-math-expr"><xsl:value-of select="@initialConcentration"/></span>
      <span class="heta-end">;
</span>
    </span>
  </xsl:template>

  <xsl:template
    match="*[local-name()='species' and @initialAmount and (@hasOnlySubstanceUnits='true' or key('idKey',@compartment)/@spatialDimensions='0')]"
     mode="heta-assignment"
     >
    <span>
      <xsl:apply-templates select="@id" mode="heta-sugar"/>
      <span class="heta-assignments"> .= </span>
      <span class="heta-string heta-math-expr"><xsl:value-of select="@initialAmount"/></span>
      <span class="heta-end">;
</span>
    </span>
  </xsl:template>

  <xsl:template
    match="*[local-name()='species' and @initialAmount and not(@hasOnlySubstanceUnits='true' or key('idKey',@compartment)/@spatialDimensions='0')]"
    mode="heta-assignment"
    >
    <span>
      <xsl:apply-templates select="@id" mode="heta-sugar"/>
      <span class="heta-assignments"> .= </span>
      <span class="heta-string heta-math-expr"><xsl:value-of select="@initialAmount"/> / <xsl:value-of select="@compartment"/></span>
      <span class="heta-end">;
</span>
    </span>
  </xsl:template>

  <xsl:template
    match="*[local-name()='species' and @initialConcentration and (@hasOnlySubstanceUnits='true' or key('idKey',@compartment)/@spatialDimensions='0')]"
    mode="heta-assignment"
    >
    <span>
      <xsl:apply-templates select="@id" mode="heta-sugar"/>
      <span class="heta-assignments"> .= </span>
      <span class="heta-string heta-math-expr"><xsl:value-of select="@initialConcentration"/> * <xsl:value-of select="@compartment"/></span>
      <span class="heta-end">;
</span>
    </span>
  </xsl:template>

  <xsl:template
    match="*[local-name()='species' and (@initialAmount='0' or @initialConcentration='0')]"
    mode="heta-assignment"
    >
    <span>
      <xsl:apply-templates select="@id" mode="heta-sugar"/>
      <span class="heta-assignments"> .= </span>
      <span class="heta-string heta-math-expr">0</span>
      <span class="heta-end">;
</span>
    </span>
  </xsl:template>

  <xsl:template
    match="*[local-name()='parameter' and @value and not(@constant='true')]"
    mode="heta-assignment"
    >
    <span>
      <xsl:apply-templates select="@id" mode="heta-sugar"/>
      <span class="heta-assignments"> .= </span>
      <span class="heta-string heta-math-expr"> <xsl:value-of select="@value"/></span>
      <span class="heta-end">;
</span>
    </span>
  </xsl:template>

  <xsl:template
    match="*[local-name()='parameter' and @value and @constant='true']"
    mode="heta-assignment"
    >
    <span>
      <xsl:apply-templates select="@id" mode="heta-sugar"/>
      <span class="heta-assignments"> = </span>
      <span class="heta-string heta-math-expr"> <xsl:value-of select="@value"/></span>
      <span class="heta-end">;
</span>
    </span>
  </xsl:template>

  <xsl:template 
    match="*[local-name()='reaction' and *[local-name()='kineticLaw']/mml:math]"
    mode="heta-assignments-ode"
    >
    <span>
      <xsl:apply-templates select="@id" mode="heta-sugar"/>
      <span class="heta-assignments"> := </span>
      <span class="heta-string heta-math-expr">
        <xsl:apply-templates select="*[local-name()='kineticLaw']/mml:math"/>
      </span>
      <span class="heta-end">;
</span>
    </span>
  </xsl:template>

<!-- END assignments -->

<!-- BEGIN dictionary -->

  <!-- base dict -->
  <xsl:template
    match="*"
    mode="heta-dict"
    >
    <span class="heta-dict"> {
<xsl:apply-templates select="@*" mode="heta-dict-item"/>
    <xsl:apply-templates select="." mode="heta-dict-boundary"/>
    <xsl:apply-templates select="." mode="heta-dict-is-amount"/>
    <xsl:apply-templates select="." mode="heta-dict-aux"/>
    <xsl:text>}</xsl:text></span>
  </xsl:template>

  <!-- reaction dict -->
  <xsl:template
    match="*[local-name()='reaction']"
    mode="heta-dict"
    >
    <span class="heta-dict"> {
<xsl:apply-templates select="@*" mode="heta-dict-item"/>
      <xsl:apply-templates select="." mode="heta-dict-actors"/>
      <xsl:apply-templates select="*[local-name()='listOfModifiers']" mode="heta-dict-item"/>
      <xsl:apply-templates select="." mode="heta-dict-aux"/>
      <xsl:text>}</xsl:text></span>
  </xsl:template>

  <!-- aux item -->
  <xsl:template
    match="*"
    mode="heta-dict-aux"
    >
    <xsl:variable 
      name="auxProp"
      select="@spatialDimensions|@metaid|@sboTerm|@outside|@spatialSizeUnits|@charge|*[local-name()='annotation']"
      />
    <xsl:if test="$fullForm='true' and count($auxProp)!='0'">
    <span class="heta-dict-key">  aux: </span>
    <span class="heta-dict">{<xsl:apply-templates select="$auxProp" mode="heta-dict-aux-item"/>}
</span>
    </xsl:if>
  </xsl:template>

  <!-- annotation item -->
  <xsl:template
    match="*[local-name()='annotation']"
    mode="heta-dict-aux-item"
    >
    <xsl:if test="position()=1"><xsl:text>
  </xsl:text></xsl:if>
    <span class="heta-dict-key">  annotation: </span>
    <span class="heta-dict-item heta-array">[<xsl:apply-templates select="*" mode="heta-dict-aux-annotation"/>]
  </span>
  </xsl:template>

<!-- END dictionary -->

<!-- BEGIN properties -->

  <xsl:template 
    match="@*"
    mode="heta-dict-item"
    ><!-- all this properties -->
    </xsl:template>

  <xsl:template 
    match="
      @compartmentType
      |@speciesType
      "
    mode="heta-dict-item"
    >
    <span class="heta-dict-key">  tags: </span>
    <span class="heta-array heta-dict-value">[<span class="heta-string"><xsl:value-of select="."/></span>]</span>,
</xsl:template>

  <xsl:template 
    match="@units"
    mode="heta-dict-item"
    >
    <span class="heta-dict-key">  units: </span>
    <span class="heta-string heta-dict-value"><xsl:value-of select="."/></span>,
</xsl:template>

  <xsl:template 
    match="@substanceUnits"
    mode="heta-dict-item"
    >
    <xsl:if test="not((../@hasOnlySubstanceUnits='true') or key('idKey',../@compartment)/@spatialDimensions='0')and key('idKey', ../@compartment)/@units">
      <span class="heta-dict-key">  units: </span>
      <span class="heta-dict-value heta-string"><xsl:value-of select="."/>/<xsl:value-of select="key('idKey', ../@compartment)/@units"/></span>,
</xsl:if>
    <xsl:if test="../@hasOnlySubstanceUnits='true' or key('idKey',../@compartment)/@spatialDimensions='0'">
    <span class="heta-dict-key">  units: </span>
    <span class="heta-dict-value heta-string"><xsl:value-of select="."/></span>,
</xsl:if>
</xsl:template>

  <xsl:template
    match="@compartment"
    mode="heta-dict-item"
    >
    <span class="heta-dict-key">  compartment: </span>
    <span class="heta-dict-value heta-string"><xsl:value-of select="."/></span>,
</xsl:template>
<!--
  <xsl:template
    match="@hasOnlySubstanceUnits"
    mode="heta-dict-item"
    >
    <span class="heta-dict-key"> isAmount: </span>
    <span class="heta-boolean heta-dict-value"><xsl:value-of select="."/></span>,
</xsl:template>
-->
  <xsl:template
    match="*[local-name()='reaction']"
    mode="heta-dict-actors"
    >
    <span class="heta-dict-key">  actors: </span>
    <span class="heta-dict-value heta-string"><xsl:apply-templates select="." mode="reactionFormula"/></span>,
</xsl:template>

  <xsl:template
    match="*[local-name()='listOfModifiers']"
    mode="heta-dict-item"
    >
    <span class="heta-dict-key">  modifiers: </span>
    <span class="heta-dict-value heta-array"><xsl:apply-templates select="." mode="reactionFormula"/></span>,
</xsl:template>

  <!-- no boundary as default -->
  <xsl:template
    match="*"
    mode="heta-dict-boundary"
    >
</xsl:template>

  <!-- boundary for compartment -->
  <xsl:template
    match="*[local-name()='compartment' and not(@constant='false')]"
    mode="heta-dict-boundary"
    >
    <span class="heta-dict-key">  boundary: </span>
    <span class="heta-boolean heta-dict-value">true</span>,
</xsl:template>

  <!-- boundary for species -->
  <xsl:template
    match="*[local-name()='species' and (@boundaryCondition='true' or @constant='true')]"
    mode="heta-dict-boundary"
    >
    <span class="heta-dict-key">  boundary: </span>
    <span class="heta-boolean heta-dict-value">true</span>,
</xsl:template>

  <!-- isAmount for species -->
  <xsl:template
      match="*"
      mode="heta-dict-is-amount"
      >
  </xsl:template>
  <xsl:template
    match="*[local-name()='species' and (@hasOnlySubstanceUnits='true' or key('idKey',@compartment)/@spatialDimensions='0')]"
    mode="heta-dict-is-amount"
    >
    <span class="heta-dict-key">  isAmount: </span>
    <span class="heta-boolean heta-dict-value">true</span>,
</xsl:template>
<!-- END properties -->

<!-- BEGIN reactionFormula mode -->
  <xsl:template
    match="*[local-name()='reaction']" 
    mode="reactionFormula"
    >
    <xsl:if test="count(*[local-name()='listOfReactants']/*[local-name()='speciesReference'])=0"></xsl:if>
    <xsl:apply-templates select="*[local-name()='listOfReactants']" mode="reactionFormula"/>
    <xsl:if test="@reversible='false' and @fast='true'"> -> </xsl:if>
    <xsl:if test="not(@reversible='false') and @fast='true'"> &#60;-> </xsl:if>
    <xsl:if test="@reversible='false' and not(@fast='true')"> => </xsl:if>
    <xsl:if test="not(@reversible='false') and not(@fast='true')"> &#60;=> </xsl:if>
    <xsl:if test="count(*[local-name()='listOfProducts']/*[local-name()='speciesReference'])=0"></xsl:if>
    <xsl:apply-templates select="*[local-name()='listOfProducts']" mode="reactionFormula"/>
  </xsl:template>

  <!-- listOfReactants / listOfProducts-->
  <xsl:template 
    match="
      *[local-name()='listOfReactants']
      |*[local-name()='listOfProducts']
      " 
    mode="reactionFormula"
    >
    <xsl:for-each select="*[local-name()='speciesReference']">
      <xsl:if test="@stoichiometry!='1'"><xsl:value-of select="@stoichiometry"/>*</xsl:if>
    <xsl:value-of select="@species"/>
      <xsl:if test="position()!=last()"> + </xsl:if>
    </xsl:for-each>
  </xsl:template>

  <!-- listOfModifiers-->
  <xsl:template 
    match="*[local-name()='listOfModifiers']"
    mode="reactionFormula"
    >[<xsl:for-each select="*[local-name()='modifierSpeciesReference']">
    <span class="heta-array-item heta-string"><xsl:value-of select="@species"/></span>
      <xsl:if test="position()!=last()">, </xsl:if>
    </xsl:for-each>]</xsl:template>
<!-- END reactionFormula mode -->

<!-- BEGIN aux properties -->
  <!-- all other prop -->
  <xsl:template
    match="@*"
    mode="heta-dict-aux-item"
    >
    <xsl:if test="position()=1"><xsl:text>
  </xsl:text></xsl:if>
    <xsl:text>  </xsl:text>
    <span class="heta-dict-key"><xsl:value-of select="local-name()"/>: </span>
    <span class="heta-dict-value heta-string"><xsl:value-of select="."/></span><xsl:if test="position()!=last()">,</xsl:if><xsl:text>
  </xsl:text>
  </xsl:template>

<!-- END aux properties -->

<!-- BEGIN annotation properties -->

  <xsl:template
    match="*"
    mode="heta-dict-aux-annotation"
    >
    <xsl:text>{</xsl:text>
    <span class="heta-dict-key">type</span>: <span class="heta-dict-value heta-string">element</span><xsl:text>, </xsl:text>
      <span class="heta-dict-key">name</span>: <span class="heta-dict-value heta-string"><xsl:value-of select="name()"/></span><xsl:text>, </xsl:text>
      <!--<span class="heta-dict-key">uri_</span>: <span class="heta-dict-value heta-string"><xsl:value-of select="namespace-uri()"/></span>,-->
      <xsl:if test="count(@*)"><span class="heta-dict-key">attributes</span>: <span class="heta-array">[<xsl:apply-templates select="@*" mode="heta-dict-aux-annotation-attributes"/>]</span><xsl:if test="count(*)>0">, </xsl:if></xsl:if>
      <xsl:apply-templates select="." mode="heta-dict-aux-annotation-elements"/>
    <xsl:text>}</xsl:text>
  </xsl:template>

  <xsl:template
    match="*[count(*)>0]"
    mode="heta-dict-aux-annotation-elements"
    >
    <span class="heta-dict-key">elements</span><xsl:text>: </xsl:text>
    <span class="heta-array">[<xsl:apply-templates select="*" mode="heta-dict-aux-annotation"/>]</span>
  </xsl:template>

  <xsl:template
    match="@*"
    mode="heta-dict-aux-annotation-attributes"
    >
    <span class="heta-dict-key"><xsl:value-of select="name()"/></span>
    <xsl:text>: </xsl:text>
    <span class="heta-dict-value heta-string"><xsl:value-of select="."/></span>
  </xsl:template>

<!-- END annotation properties -->

<!-- BEGIN MathML -->

  <!-- unknown mml element -->
  <xsl:template match="mml:*">
    <span class="heta-debug"> { unsupported MathML } </span>
  </xsl:template>

  <xsl:template match="mml:math">
    <xsl:apply-templates select="*"/>
  </xsl:template>

  <!-- any mathml internal function without changes -->
  <xsl:template match="mml:apply">
    <xsl:value-of select="local-name(*[1])"/>
    <xsl:apply-templates select="." mode="arguments"/>
  </xsl:template>

  <!-- log -->
  <xsl:template match="mml:apply[mml:log]">
    <xsl:text>log10</xsl:text>
    <xsl:apply-templates select="." mode="arguments"/>
  </xsl:template>

  <!-- log_base -->
  <xsl:template match="mml:apply[mml:log and mml:logbase]">
    <xsl:text>log</xsl:text>
    <xsl:text>(</xsl:text>
    <xsl:apply-templates select="mml:ci|mml:cn"/>, <xsl:apply-templates select="mml:logbase/mml:ci|mml:logbase/mml:cn"/>
    <xsl:text>)</xsl:text>
  </xsl:template>

  <!-- log_base -->
  <xsl:template match="mml:apply[mml:log and mml:logbase and mml:logbase/mml:cn and number(mml:logbase/mml:cn)=2]">
    <xsl:text>log</xsl:text>
    <xsl:text>(</xsl:text>
    <xsl:apply-templates select="mml:ci|mml:cn"/>
    <xsl:text>)</xsl:text>
  </xsl:template>

  <!-- power -->
  <xsl:template match="mml:apply[mml:power]">
    <xsl:text>pow</xsl:text>
    <xsl:apply-templates select="." mode="arguments"/>
  </xsl:template>

  <!-- root -->
  <xsl:template match="mml:apply[mml:power]">
    <xsl:text>sqrt</xsl:text>
    <xsl:apply-templates select="." mode="arguments"/>
  </xsl:template>

  <!-- max 1
  <xsl:template match="mml:apply[mml:max and count(mml:*)=2]">
    <xsl:apply-templates select="mml:*[2]"/>
  </xsl:template> -->

  <!-- max 2
  <xsl:template match="mml:apply[mml:max and count(mml:*)=3]">
    <xsl:text>max2</xsl:text>
    <xsl:apply-templates select="." mode="arguments"/>
  </xsl:template> -->

  <!-- max 3
  <xsl:template match="mml:apply[mml:max and count(mml:*)=4]">
    <xsl:text>max3</xsl:text>
    <xsl:apply-templates select="." mode="arguments"/>
  </xsl:template> -->

  <!-- min 1
  <xsl:template match="mml:apply[mml:min and count(mml:*)=2]">
    <xsl:apply-templates select="mml:*[2]"/>
  </xsl:template> -->

  <!-- min 2
  <xsl:template match="mml:apply[mml:min and count(mml:*)=3]">
    <xsl:text>min2</xsl:text>
    <xsl:apply-templates select="." mode="arguments"/>
  </xsl:template> -->

  <!-- min 3
  <xsl:template match="mml:apply[mml:min and count(mml:*)=4]">
    <xsl:text>min3</xsl:text>
    <xsl:apply-templates select="." mode="arguments"/>
  </xsl:template> -->

  <!-- function arguments -->
  <xsl:template match="mml:apply" mode="arguments">
    <xsl:text>(</xsl:text>
    <xsl:for-each select="*[position()&gt;1]">
      <xsl:apply-templates select="."/>
      <xsl:if test="position()!=last()">, </xsl:if>
    </xsl:for-each>
    <xsl:text>)</xsl:text>
  </xsl:template>

  <!-- x*y*z -->
  <xsl:template match="mml:apply[mml:times]">
    <xsl:for-each select="*[position()&gt;1]">
      <xsl:apply-templates select="."/><xsl:if test="position()!=last()"> * </xsl:if>
    </xsl:for-each>
  </xsl:template>

  <!-- x/y/z -->
  <xsl:template match="mml:apply[mml:divide]">
    <xsl:for-each select="*[position()&gt;1]">
      <xsl:apply-templates select="."/><xsl:if test="position()!=last()"> / </xsl:if>
    </xsl:for-each>
  </xsl:template>

  <!-- x-y-z -->
  <xsl:template match="mml:apply[mml:minus]">
    <xsl:for-each select="*[position()&gt;1]">
      <xsl:apply-templates select="."/>
      <xsl:if test="position()!=last()"> - </xsl:if>
    </xsl:for-each>
  </xsl:template>

  <!-- x+y+z -->
  <xsl:template match="mml:apply[mml:plus]">
    <xsl:for-each select="*[position()&gt;1]">
      <xsl:apply-templates select="."/>
      <xsl:if test="position()!=last()"> + </xsl:if>
    </xsl:for-each>
  </xsl:template>

  <!-- arbitrary functions as ci fun(x, y, z) -->
  <xsl:template match="mml:apply[*[1][self::mml:ci]]">
    <xsl:apply-templates select="mml:ci[1]"/>
    <xsl:apply-templates select="." mode="arguments"/>
  </xsl:template>

  <!-- a*(x-y-z) a/(x-y-z) a-(x-y-z)-->
  <xsl:template match="mml:apply[mml:times or mml:divide or mml:minus]/mml:apply[mml:minus]">
    <xsl:text>(</xsl:text>
    <xsl:for-each select="*[position()&gt;1]">
      <xsl:apply-templates select="."/>
      <xsl:if test="position()!=last()"> - </xsl:if>
    </xsl:for-each>
    <xsl:text>)</xsl:text>
  </xsl:template>

  <!-- a*(x+y+z) a/(x+y+z) a-(x+y+z) -->
  <xsl:template match="mml:apply[mml:times or mml:divide or mml:minus]/mml:apply[mml:plus]">
    <xsl:text> (</xsl:text>
    <xsl:for-each select="*[position()&gt;1]">
      <xsl:apply-templates select="."/>
      <xsl:if test="position()!=last()"> + </xsl:if>
    </xsl:for-each>
    <xsl:text>) </xsl:text>
  </xsl:template>

  <!-- peicewise with many pieces-->
  <xsl:template match="mml:piecewise">
    <span class="heta-debug"> { use only one piece in MathML peicewise } </span>
  </xsl:template>

  <!-- piecewise lt -->
  <xsl:template match="mml:piecewise[count(mml:piece)=1][mml:piece/mml:apply/*[1][self::mml:lt]]">
    <xsl:text>ifg0(</xsl:text>
    <xsl:apply-templates select="mml:piece/mml:apply/*[3]"/>-<xsl:apply-templates select="mml:piece/mml:apply/*[2]"/>, <xsl:apply-templates select="mml:piece/*[1]"/>, <xsl:apply-templates select="mml:otherwise/*[1]" />
    <xsl:text>)</xsl:text>
  </xsl:template>

  <!-- piecewise gt -->
  <xsl:template match="mml:piecewise[count(mml:piece)=1][mml:piece/mml:apply/*[1][self::mml:gt]]">
    <xsl:text>ifg0(</xsl:text>
    <xsl:apply-templates select="mml:piece/mml:apply/*[2]"/>-<xsl:apply-templates select="mml:piece/mml:apply/*[3]"/>, <xsl:apply-templates select="mml:piece/*[1]"/>, <xsl:apply-templates select="mml:otherwise/*[1]" />
    <xsl:text>)</xsl:text>
  </xsl:template>

  <!-- piecewise leq -->
  <xsl:template match="mml:piecewise[count(mml:piece)=1][mml:piece/mml:apply/*[1][self::mml:leq]]">
    <xsl:text>ifge0(</xsl:text>
    <xsl:apply-templates select="mml:piece/mml:apply/*[3]"/>-<xsl:apply-templates select="mml:piece/mml:apply/*[2]"/>, <xsl:apply-templates select="mml:piece/*[1]"/>, <xsl:apply-templates select="mml:otherwise/*[1]" />
    <xsl:text>)</xsl:text>
  </xsl:template>

  <!-- piecewise geq -->
  <xsl:template match="mml:piecewise[count(mml:piece)=1][mml:piece/mml:apply/*[1][self::mml:geq]]">
    <xsl:text>ifge0(</xsl:text>
    <xsl:apply-templates select="mml:piece/mml:apply/*[2]"/>-<xsl:apply-templates select="mml:piece/mml:apply/*[3]"/>, <xsl:apply-templates select="mml:piece/*[1]"/>, <xsl:apply-templates select="mml:otherwise/*[1]" />
    <xsl:text>)</xsl:text>
  </xsl:template>

  <!-- piecewise eq -->
  <xsl:template match="mml:piecewise[count(mml:piece)=1][mml:piece/mml:apply/*[1][self::mml:eq]]">
    <xsl:text>ife0(</xsl:text>
    <xsl:apply-templates select="mml:piece/mml:apply/*[2]"/>-<xsl:apply-templates select="mml:piece/mml:apply/*[3]"/>, <xsl:apply-templates select="mml:piece/*[1]"/>, <xsl:apply-templates select="mml:otherwise/*[1]" />
    <xsl:text>)</xsl:text>
  </xsl:template>

  <!-- piecewise neq -->
  <xsl:template match="mml:piecewise[count(mml:piece)=1][mml:piece/mml:apply/*[1][self::mml:neq]]">
    <xsl:text>ife0(</xsl:text>
    <xsl:apply-templates select="mml:piece/mml:apply/*[2]"/>-<xsl:apply-templates select="mml:piece/mml:apply/*[3]"/>, <xsl:apply-templates select="mml:otherwise/*[1]"/>, <xsl:apply-templates select="mml:piece/*[1]"/>
    <xsl:text>)</xsl:text>
  </xsl:template>

  <xsl:template match="mml:ci">
    <xsl:value-of select="normalize-space(text())"/>
  </xsl:template>

  <xsl:template match="mml:cn">
    <xsl:value-of select="normalize-space(text())"/>
  </xsl:template>

  <xsl:template match="mml:cn[number(text()) &lt; 0]">
    <xsl:text>(</xsl:text>
    <xsl:value-of select="normalize-space(text())"/>
    <xsl:text>)</xsl:text>
  </xsl:template>

  <xsl:template match="mml:csymbol[@definitionURL='http://www.sbml.org/sbml/symbols/time']">
    <xsl:text>t</xsl:text>
  </xsl:template>

<!-- END MathML -->

<!-- BEGIN XHTML -->
  <!-- <xsl:strip-space elements="xhtml:body xhtml:div xhtml:pre xhtml:p" /> -->

  <xsl:template match="xhtml:*">
    <span class="heta-debug"><xsl:apply-templates select="node()"/></span>
  </xsl:template>

  <xsl:template match="xhtml:*/text()">
    <xsl:value-of select="translate(., '&#xa;', '')"/> <!-- &#xa; new line -->
  </xsl:template>

  <xsl:template
    match="
      xhtml:div
      |xhtml:pre
      |xhtml:p
      "
    >
    <xsl:text>
</xsl:text>
    <xsl:apply-templates select="node()"/>
    <xsl:text>
</xsl:text>
  </xsl:template>

  <xsl:template
    match="xhtml:i"
    >
    <xsl:text>*</xsl:text><xsl:apply-templates select="node()"/><xsl:text>*</xsl:text>
  </xsl:template>

  <xsl:template
    match="
      xhtml:b
      |xhtml:strong
      "
    >
    <xsl:text>**</xsl:text><xsl:apply-templates select="node()"/><xsl:text>**</xsl:text>
  </xsl:template>

  <xsl:template
    match="xhtml:a"
    >
    <xsl:text> [</xsl:text>
    <xsl:apply-templates select="node()"/>
    <xsl:text>](</xsl:text>
    <xsl:value-of select="@href"/>
    <xsl:text>) </xsl:text>
  </xsl:template>
  <!-- remove first level -->
  <xsl:template
    match="*[local-name()='notes']/xhtml:*"
    >
    <xsl:apply-templates select="node()"/>
  </xsl:template>
  <!--
      <xsl:for-each select="node()">
      <xsl:if test="(position()!=last() and position()!=1) or normalize-space()!=''">
        <xsl:apply-templates select="."/>
      </xsl:if>
    </xsl:for-each>
  -->

<!-- END XHTML -->

</xsl:stylesheet>
