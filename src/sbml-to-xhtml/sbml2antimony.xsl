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
Description: Creating representation of SBML in Antimony format.
Source files: SBML L2 V1-5
TODO:
  * local parameters in reactions
  * check function list

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
  xmlns:exsl="http://exslt.org/common"
  xmlns:msexsl="urn:schemas-microsoft-com:xslt"
  exclude-result-prefixes="mml xhtml l2v1 l2v2 l2v3 l2v4 l2v5">

  <xsl:output encoding="UTF-8" indent="no"/>

  <!-- GLOBAL KEYS -->
  <xsl:key name="idKey" match="*" use="@id"/>

  <!-- PARAMETERS -->
  <!-- no input parameters -->
  <xsl:param name="reserved">
    <w>model</w>
    <w>compartment</w>
    <w>species</w>
    <w>function</w>
    <w>unit</w>
    <w>formula</w>
    <w>const</w>
    <w>is</w>
    <w>time</w>
    <w>at</w>
    <w>after</w>
  </xsl:param>

  <!-- top -->
  <xsl:template match="/">
    <xsl:apply-templates mode="antimony"/>
  </xsl:template>

  <!-- SBML -->
  <xsl:template match="*[local-name()='sbml']" mode="antimony">
    <div class="sv-container sv-mode-antimony">
      <h3 class="sv-header">Transformation from SBML L<xsl:value-of select="@level"/>V<xsl:value-of select="@version"/> to Antimony</h3>
      <h4 class="sv-header">See more in <a href="https://tellurium.readthedocs.io" target="blank_">https://tellurium.readthedocs.io</a></h4>
      <div class="sv-content antimony-code">
        <xsl:apply-templates select="*[local-name()='model']" mode="antimony"/>
      </div>
    </div>
  </xsl:template>

  <!-- model -->
  <xsl:template match="*[local-name()='model']" mode="antimony">
    <pre>
    <span class="antimony-reserved">model</span>    
    <xsl:apply-templates select="@id" mode="antimony-id"/><xsl:if test="not(@id)">noname</xsl:if>
    <xsl:text>()</xsl:text>
    <xsl:apply-templates select="*[contains(local-name(), 'listOf')]" mode="antimony"/>
    <span class="antimony-reserved">

end</span>
    </pre>
  </xsl:template>

  <!-- notes -->
  <xsl:template match="*[local-name()='notes']" mode="antimony">
  </xsl:template>

  <!-- id -->
  <xsl:template match="@id|@symbol|@variable|@outside|@compartment|@kind|@units|@substanceUnits" mode="antimony">
    <xsl:value-of select="."/>
    <xsl:if test="exsl:node-set($reserved)/*[current()=text()]">_</xsl:if> <!-- if reserved add _ -->
  </xsl:template>

  <xsl:template match="@id|@symbol|@variable" mode="antimony-id">
    <span class="antimony-id">
      <xsl:text> </xsl:text>
      <xsl:apply-templates select="." mode="antimony"/>
    </span>
  </xsl:template>

  <!-- name -->
  <xsl:template match="@name" mode="antimony">
    <span class="antimony-reserved"> is</span>
    <xsl:text> "</xsl:text>
    <xsl:value-of select="."/>
    <xsl:text>"</xsl:text>
  </xsl:template>

<!-- BEGIN listOf -->
  <!-- unsupported listOf... -->
  <xsl:template 
    match="*[contains(local-name(), 'listOf')]"
    mode="antimony"
    >
    <span class="antimony-comment">

# <xsl:value-of select="local-name()"/> (not supported)</span>
      <span class="antimony-comment">
/* not supported in current version */
</span>
  </xsl:template>

  <!-- listOfFunctionDefinitions -->
  <xsl:template 
    match="*[local-name()='listOfFunctionDefinitions']"
    mode="antimony"
    >
    <span class="antimony-comment">

  # listOfFunctionDefinitions</span>
    <xsl:apply-templates select="*[local-name()='functionDefinition']" mode="antimony"/>
  </xsl:template>

  <!-- listOfConstraints -->
  <xsl:template 
    match="*[local-name()='listOfConstraints']"
    mode="antimony"
    >
    <span class="antimony-comment">
    <xsl:text>

  # listOfConstraints (not supported)</xsl:text>
    <xsl:text>
  /*
  The original model contains the following constraints:</xsl:text>
    <xsl:apply-templates select="*[local-name()='constraint']" mode="antimony"/>
    <xsl:text>
  */</xsl:text>
    </span>
  </xsl:template>

  <!-- listOfCompartmentTypes -->
  <xsl:template 
    match="*[local-name()='listOfCompartmentTypes']"
    mode="antimony"
    >
    <span class="antimony-comment">
    <xsl:text>

  # listOfCompartmentTypes (not supported)
</xsl:text>
    <xsl:text>  /*
  The original model contains the following compartmentTypes:
  </xsl:text>
    <xsl:apply-templates select="*[local-name()='compartmentType']" mode="antimony"/>
    <xsl:text>
  */</xsl:text>
    </span>
  </xsl:template>


  <!-- listOfSpeciesTypes -->
  <xsl:template 
    match="*[local-name()='listOfSpeciesTypes']"
    mode="antimony"
    >
    <span class="antimony-comment">
    <xsl:text>

  # listOfSpeciesTypes (not supported)
</xsl:text>
    <xsl:text>  /*
  The original model contains the following speciesTypes:
  </xsl:text>
    <xsl:apply-templates select="*[local-name()='speciesType']" mode="antimony"/>
    <xsl:text>
  */</xsl:text>
    </span>
  </xsl:template>

  <!-- listOfUnitDefinitions -->
  <xsl:template 
    match="*[local-name()='listOfUnitDefinitions']"
    mode="antimony"
    >
    <span class="antimony-comment">

  # listOfUnitDefinitions</span>
    <xsl:apply-templates select="*[local-name()='unitDefinition']" mode="antimony"/>
  </xsl:template>

  <!-- listOfCompartments -->
  <xsl:template 
    match="*[local-name()='listOfCompartments']"
    mode="antimony"
    >
    <span class="antimony-comment">

  # listOfCompartments</span>
    <xsl:apply-templates select="*[local-name()='compartment']" mode="antimony"/>
  </xsl:template>

  <!-- listOfSpecies -->
  <xsl:template 
    match="*[local-name()='listOfSpecies']"
    mode="antimony"
    >
    <span class="antimony-comment">

  # listOfSpecies</span>
    <xsl:apply-templates select="*[local-name()='species']" mode="antimony"/>
  </xsl:template>

  <!-- listOfParameters -->
  <xsl:template 
    match="*[local-name()='listOfParameters']" 
    mode="antimony"
    >
    <span class="antimony-comment">

  # listOfParameters</span>
    <xsl:apply-templates select="*[local-name()='parameter']" mode="antimony"/>
  </xsl:template>

  <!-- listOfReactions -->
  <xsl:template 
    match="*[local-name()='listOfReactions']" 
    mode="antimony"
    >
    <span class="antimony-comment">

  # listOfReactions</span>
    <xsl:apply-templates select="*[local-name()='reaction']" mode="antimony"/>
  </xsl:template>

  <!-- listOfInitialAssignments -->
  <xsl:template 
    match="*[local-name()='listOfInitialAssignments']" 
    mode="antimony"
    >
    <span class="antimony-comment">

  # listOfInitialAssignments</span>
    <xsl:apply-templates select="*[local-name()='initialAssignment']" mode="antimony"/>
  </xsl:template>

  <!-- listOfRules -->
  <xsl:template 
    match="*[local-name()='listOfRules']" 
    mode="antimony"
    >
    <span class="antimony-comment">

  # listOfRules</span>
    <xsl:apply-templates select="*[local-name()='assignmentRule']|*[local-name()='rateRule']|*[local-name()='algebraicRule']" mode="antimony"/>
  </xsl:template>

  <!-- listOfEvents -->
  <xsl:template 
    match="*[local-name()='listOfEvents']" 
    mode="antimony"
    >
    <span class="antimony-comment">

  # listOfEvents</span>
    <xsl:apply-templates select="*[local-name()='event']" mode="antimony"/>
  </xsl:template>

<!-- END listOf -->

<!-- BEGIN unsupported components -->

  <xsl:template 
    match="*[local-name()='functionDefinition']" 
    mode="antimony"
    >
    <span class="antimony-reserved">
  function</span>
    <xsl:apply-templates select="@id" mode="antimony-id"/>
    <xsl:text>(</xsl:text>
    <xsl:apply-templates select="mml:math/mml:lambda/mml:bvar/mml:ci" mode="lambda"/>
    <xsl:text>)
    </xsl:text>
    <xsl:apply-templates select="mml:math/mml:lambda/*[local-name()!='bvar']"/>
    <span class="antimony-reserved">
  end</span>
</xsl:template>

  <xsl:template 
    match="*[local-name()='constraint']" 
    mode="antimony"
    >
    <xsl:text>
  </xsl:text>
    <xsl:apply-templates select="mml:math"/>
  </xsl:template>

  <xsl:template 
    match="*[local-name()='compartmentType']" 
    mode="antimony"
    >
    <xsl:if test="position()!=1">, </xsl:if>
    <xsl:apply-templates select="@id" mode="antimony"/>
  </xsl:template>

  <xsl:template 
    match="*[local-name()='speciesType']" 
    mode="antimony"
    >
    <xsl:if test="position()!=1">, </xsl:if>
    <xsl:apply-templates select="@id" mode="antimony"/>
  </xsl:template>

<!-- END unsupported components -->

<!-- BEGIN components -->

  <xsl:template 
    match="*[local-name()='unitDefinition']" 
    mode="antimony"
    >
    <xsl:text>
 </xsl:text>
    <xsl:apply-templates select="." mode="antimony-class"/>
    <xsl:apply-templates select="@id" mode="antimony-id"/>
    <xsl:text> = </xsl:text>
    <xsl:apply-templates select="*[local-name()='listOfUnits']/*[local-name()='unit']" mode="unitFormula"/>
    <xsl:text>;</xsl:text>
  </xsl:template>

  <xsl:template 
    match="*[local-name()='compartment']"
    mode="antimony"
    >
    <xsl:text>
 </xsl:text>
    <xsl:apply-templates select="." mode="antimony-const"/>
    <xsl:apply-templates select="." mode="antimony-class"/>
    <xsl:apply-templates select="@id" mode="antimony-id"/>
    <xsl:apply-templates select="@outside" mode="antimony-in"/>
    <xsl:apply-templates select="@name" mode="antimony"/>
    <xsl:apply-templates select="." mode="antimony-assignment"/>
    <xsl:apply-templates select="@units" mode="antimony-units"/>
    <xsl:text>;</xsl:text>
  </xsl:template>

  <xsl:template 
    match="*[local-name()='species']"
    mode="antimony"
    >
    <xsl:text>
 </xsl:text>
    <xsl:apply-templates select="." mode="antimony-const"/>
    <xsl:apply-templates select="@hasOnlySubstanceUnits" mode="antimony"/>
    <xsl:apply-templates select="." mode="antimony-class"/>
    <xsl:apply-templates select="@id" mode="antimony-id"/>
    <xsl:apply-templates select="@compartment" mode="antimony-in"/>
    <xsl:apply-templates select="@name" mode="antimony"/>
    <xsl:apply-templates select="." mode="antimony-assignment"/>
    <xsl:text>;</xsl:text>
  </xsl:template>

  <xsl:template 
    match="*[local-name()='parameter']"
    mode="antimony"
    >
    <xsl:text>
 </xsl:text>
    <xsl:apply-templates select="." mode="antimony-const"/>
    <xsl:apply-templates select="." mode="antimony-class"/>
    <xsl:apply-templates select="@id" mode="antimony-id"/>
    <xsl:apply-templates select="@name" mode="antimony"/>
    <xsl:apply-templates select="." mode="antimony-assignment"/>
    <xsl:apply-templates select="@units" mode="antimony-units"/>
    <xsl:text>;</xsl:text>
  </xsl:template>

  <xsl:template 
    match="*[local-name()='reaction']" 
    mode="antimony"
    >
    <xsl:text>
 </xsl:text>
    <xsl:apply-templates select="@id" mode="antimony-id"/>
    <xsl:apply-templates select="@name" mode="antimony"/>
    <xsl:text>: </xsl:text>
    <xsl:apply-templates select="." mode="reactionFormula"/>
    <xsl:apply-templates select="." mode="antimony-assignment"/>
    <xsl:text></xsl:text>
  </xsl:template>

  <xsl:template 
    match="*[local-name()='initialAssignment']" 
    mode="antimony"
    >
    <xsl:text> 
 </xsl:text>
    <xsl:apply-templates select="@symbol" mode="antimony-id"/>
    <xsl:text> = </xsl:text>
    <xsl:apply-templates select="mml:math"/>
    <xsl:text>;</xsl:text>
  </xsl:template>

  <xsl:template 
    match="*[local-name()='assignmentRule']" 
    mode="antimony"
    >
    <xsl:text> 
 </xsl:text>
    <xsl:apply-templates select="@variable" mode="antimony-id"/>
    <xsl:text> := </xsl:text>
    <xsl:apply-templates select="mml:math"/>
    <xsl:text>; </xsl:text>
    <span class="antimony-comment"># assignmentRule</span>
  </xsl:template>

  <xsl:template 
    match="*[local-name()='rateRule']" 
    mode="antimony"
    >
    <xsl:text>
 </xsl:text>
    <xsl:apply-templates select="@variable" mode="antimony-id"/>
    <xsl:text>' = </xsl:text>
    <xsl:apply-templates select="mml:math"/>
    <xsl:text>; </xsl:text>
    <span class="antimony-comment"># rateRule</span>
  </xsl:template>

  <xsl:template 
    match="*[local-name()='algebraicRule']" 
    mode="antimony"
    >
    <span class="antimony-comment">
    <xsl:text>
  // 0 = </xsl:text>
    <xsl:apply-templates select="mml:math"/>
    <xsl:text>; # algebraicRule (not supported)</xsl:text>
    </span>
  </xsl:template>

  <!-- event with id -->
  <xsl:template 
    match="*[local-name()='event']" 
    mode="antimony"
    >
    <xsl:text>
 </xsl:text>
    <xsl:if test="@id"><xsl:apply-templates select="@id" mode="antimony-id"/>:</xsl:if>
    <span class="antimony-reserved"> at</span>
    <xsl:if test="*[local-name()='delay']/mml:math">
      <xsl:text> </xsl:text>
      <xsl:apply-templates select="*[local-name()='delay'][1]/mml:math"/>
      <span class="antimony-reserved"> after</span>
    </xsl:if>
    <xsl:text> (</xsl:text><xsl:apply-templates select="*[local-name()='trigger'][1]/mml:math"/><xsl:text>)</xsl:text>
    <xsl:if test="@useValuesFromTriggerTime">, fromTrigger=<xsl:value-of select="@useValuesFromTriggerTime"/></xsl:if>
    <xsl:if test="*[local-name()='trigger']/@initialValue">, t0=<xsl:value-of select="*[local-name()='trigger'][1]/@initialValue"/></xsl:if>
    <xsl:if test="*[local-name()='trigger']/@persistent">, persistent=<xsl:value-of select="*[local-name()='trigger'][1]/@persistent"/></xsl:if>
    <xsl:if test="*[local-name()='priority']/mml:math">, priority=<xsl:apply-templates select="*[local-name()='priority']/mml:math"/></xsl:if>
    <xsl:text>: </xsl:text>
    <xsl:apply-templates select="*[local-name()='listOfEventAssignments']/*[local-name()='eventAssignment']" mode="antimony-event-assignment"/>
    <xsl:text>;</xsl:text>
  </xsl:template>

  <xsl:template
    match="*[local-name()='eventAssignment']"
    mode="antimony-event-assignment"
    >
    <xsl:if test="position()!=1">, </xsl:if>
    <xsl:apply-templates select="@variable" mode="antimony"/>
    <xsl:text> = </xsl:text>
    <xsl:apply-templates select="mml:math"/>
  </xsl:template>

  <!-- const or var -->
  <xsl:template match="*" mode="antimony-const">
    <xsl:text></xsl:text>
  </xsl:template>

  <xsl:template match="*[@constant='true']" mode="antimony-const">
    <span class="antimony-reserved"> const</span>
  </xsl:template>

  <xsl:template match="*[local-name()='compartment' and not(@constant='false')]" mode="antimony-const">
    <span class="antimony-reserved"> const</span>
  </xsl:template>

  <xsl:template match="*[local-name()='compartment' and @constant='false']" mode="antimony-const">
    <span class="antimony-reserved"> var</span>
  </xsl:template>

  <!-- class -->

  <xsl:template match="*[local-name()='unitDefinition']" mode="antimony-class">
    <span class="antimony-reserved"> unit</span>
  </xsl:template>

  <xsl:template match="*[local-name()='compartment']" mode="antimony-class">
    <span class="antimony-reserved"> compartment</span>
  </xsl:template>

  <xsl:template match="*[local-name()='species']" mode="antimony-class">
    <span class="antimony-reserved"> species</span>
  </xsl:template>

  <xsl:template match="*[local-name()='parameter']" mode="antimony-class">
    <span class="antimony-reserved"></span><!-- formula -->
  </xsl:template>

  <!-- in (outside/compartment) -->
  <xsl:template match="@outside|@compartment" mode="antimony-in">
    <span class="antimony-reserved"> in </span>
    <xsl:apply-templates select="." mode="antimony"/>
  </xsl:template>
<!-- END components -->

<!-- BEGIN assignments -->

  <!-- no value -->
  <xsl:template
    match="*"
    mode="antimony-assignment"
    >
  </xsl:template>

  <xsl:template
    match="*[local-name()='compartment' and (@size or @units)]"
    mode="antimony-assignment"
    >
    <xsl:text> = </xsl:text>
    <xsl:value-of select="@size"/>
  </xsl:template>

  <xsl:template
    match="*[local-name()='species' and @initialConcentration and not(@hasOnlySubstanceUnits='true')]"
    mode="antimony-assignment"
    >
    <xsl:text> = </xsl:text>
    <xsl:value-of select="@initialConcentration"/>
    <xsl:if test="@substanceUnits and @compartment and key('idKey', @compartment)/@units">
      <xsl:apply-templates select="@substanceUnits" mode="antimony-units"/>
      <xsl:text> /</xsl:text>
      <xsl:apply-templates select="key('idKey', @compartment)/@units" mode="antimony-units"/>
    </xsl:if>
  </xsl:template>

  <xsl:template
    match="*[local-name()='species' and @initialConcentration and @hasOnlySubstanceUnits='true']"
    mode="antimony-assignment"
    >
    <xsl:text> = </xsl:text>
    <xsl:value-of select="@initialConcentration"/>
    <xsl:if test="@substanceUnits and @compartment and key('idKey', @compartment)/@units">
      <xsl:apply-templates select="@substanceUnits" mode="antimony-units"/>
      <xsl:text> /</xsl:text>
      <xsl:apply-templates select="key('idKey', @compartment)/@units" mode="antimony-units"/>
    </xsl:if>
    <xsl:text> * </xsl:text>
    <xsl:apply-templates select="@compartment" mode="antimony"/>
  </xsl:template>

  <xsl:template
    match="*[local-name()='species' and @initialAmount and not(@hasOnlySubstanceUnits='true')]"
    mode="antimony-assignment"
    >
    <xsl:text> = </xsl:text>
    <xsl:value-of select="@initialAmount"/>
    <xsl:apply-templates select="@substanceUnits" mode="antimony-units"/>
    <xsl:text> / </xsl:text>
    <xsl:apply-templates select="@compartment" mode="antimony"/>
  </xsl:template>

  <xsl:template
    match="*[local-name()='species' and @initialAmount and @hasOnlySubstanceUnits='true']"
    mode="antimony-assignment"
    >
    <xsl:text> = </xsl:text>
    <xsl:value-of select="@initialAmount"/>
    <xsl:apply-templates select="@substanceUnits" mode="antimony-units"/>
  </xsl:template>

  <xsl:template
    match="*[local-name()='parameter' and (@value or @units)]"
    mode="antimony-assignment"
    >
    <xsl:text> = </xsl:text>
    <xsl:value-of select="@value"/>
  </xsl:template>

  <xsl:template 
    match="*[local-name()='reaction' and *[local-name()='kineticLaw']/mml:math]"
    mode="antimony-assignment"
    >
    <xsl:text>; </xsl:text>
    <xsl:apply-templates select="*[local-name()='kineticLaw']/mml:math"/>
  </xsl:template>

<!-- END assignments -->

  <xsl:template 
    match="
      *[local-name()='compartment' or local-name()='parameter']/@units
      | *[local-name()='species']/@substanceUnits
    "
    mode="antimony-units"
    >
    <span class="antimony-units">
      <xsl:text> </xsl:text>
      <xsl:apply-templates select="." mode="antimony"/>
    </span>
  </xsl:template>

<!-- BEGIN properties -->

  <xsl:template
    match="*[local-name()='unit']"
    mode="unitFormula"
    >
    <xsl:if test="position()!=1"> * </xsl:if>
    <xsl:apply-templates select="." mode="unitFormulaBase"/>
    <xsl:if test="@exponent and @exponent!='1' and @exponent!='-1'">^<xsl:value-of select="format-number(number(@exponent),'0;0')"/></xsl:if>
  </xsl:template>

  <xsl:template
    match="*[local-name()='unit' and @exponent and (@exponent &lt; 0)]"
    mode="unitFormula"
    >
    <xsl:text> / </xsl:text>
    <xsl:apply-templates select="." mode="unitFormulaBase"/>
    <xsl:if test="@exponent and @exponent!='1' and @exponent!='-1'">^<xsl:value-of select="format-number(number(@exponent),'0;0')"/></xsl:if>
  </xsl:template>

  <xsl:template
    match="*[local-name()='unit']"
    mode="unitFormulaBase"
    >    
      <xsl:if test="(not(@multiplier) or @multiplier='1') and (not(@scale) or @scale='0')">
      <span class="antimony-units">
        <xsl:apply-templates select="@kind" mode="antimony"/>
      </span>
      </xsl:if>
      <xsl:if test="(@multiplier and @multiplier!='1') or (@scale and @scale!='0')">
        <xsl:if test="not(@multiplier)">1</xsl:if><xsl:value-of select="@multiplier"/>
        <xsl:text>e</xsl:text>
        <xsl:if test="not(@scale)">0</xsl:if><xsl:value-of select="@scale"/>
        <xsl:text> </xsl:text>
        <span class="antimony-units">
          <xsl:apply-templates select="@kind" mode="antimony"/>
        </span>
      </xsl:if>
    </xsl:template>

  <!-- hasOnlySubstanceUnits for species -->
  <xsl:template
      match="*[local-name()='species']/@hasOnlySubstanceUnits"
      mode="antimony"
      >
      <xsl:if test=".='true'">
        <span class="antimony-reserved"> substanceOnly</span>
      </xsl:if>
  </xsl:template>
<!-- END properties -->

<!-- BEGIN reactionFormula mode -->
  <xsl:template
    match="*[local-name()='reaction']" 
    mode="reactionFormula"
    >
    <xsl:apply-templates select="*[local-name()='listOfReactants']" mode="reactionFormula"/>
    <xsl:if test="@reversible='false'"> -> </xsl:if>
    <xsl:if test="not(@reversible='false')"> => </xsl:if>
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
      <xsl:if test="@stoichiometry!='1'"><xsl:value-of select="@stoichiometry"/><xsl:text> </xsl:text></xsl:if>
      <xsl:if test="key('idKey', @species)/@boundaryCondition='true'">$</xsl:if>
      <xsl:apply-templates select="@species" mode="antimony"/>
      <xsl:if test="position()!=last()"> + </xsl:if>
    </xsl:for-each>
  </xsl:template>
<!-- END reactionFormula mode -->

<!-- BEGIN MathML -->

  <!-- unknown mml element -->
  <xsl:template match="mml:*">
    <span class="antimony-debug"> { unsupported MathML } </span>
  </xsl:template>

  <xsl:template match="mml:math">
    <xsl:apply-templates select="*"/>
  </xsl:template>

  <!-- lambda -->
  <xsl:template match="mml:bvar/mml:ci" mode="lambda"> 
    <xsl:apply-templates select="."/>
    <xsl:if test="position()!=last()">, </xsl:if>
  </xsl:template>

  <!-- any mathml internal function without changes -->
  <xsl:template match="mml:apply">
    <xsl:value-of select="local-name(*[1])"/>
    <xsl:apply-templates select="." mode="arguments"/>
  </xsl:template>

  <!-- delay -->
  <xsl:template match="mml:apply[mml:csymbol[@definitionURL='http://www.sbml.org/sbml/symbols/delay']]">
    <i>delay</i>
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
  <xsl:template match="mml:apply[mml:root]">
    <xsl:text>nthRoot</xsl:text>
    <xsl:apply-templates select="." mode="arguments"/>
  </xsl:template>

  <!-- sqrt -->
  <xsl:template match="mml:apply[mml:root and count(*)=2]">
    <xsl:text>sqrt(</xsl:text>
    <xsl:apply-templates select="*[2]"/>
    <xsl:text>)</xsl:text>
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
    <span class="antimony-debug"> { use only one piece in MathML peicewise } </span>
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

  <!-- and -->
  <xsl:template match="mml:apply[mml:and]">
    <xsl:for-each select="*[position()&gt;1]">
      <xsl:apply-templates select="."/>
      <xsl:if test="position()!=last()"> &amp;&amp; </xsl:if>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="mml:apply/mml:apply[mml:and]">
    <xsl:text>(</xsl:text>
    <xsl:for-each select="*[position()&gt;1]">
      <xsl:apply-templates select="."/>
      <xsl:if test="position()!=last()"> &amp;&amp; </xsl:if>
    </xsl:for-each>
    <xsl:text>)</xsl:text>
  </xsl:template>

  <!-- or -->
  <xsl:template match="mml:apply[mml:or]">
    <xsl:for-each select="*[position()&gt;1]">
      <xsl:apply-templates select="."/>
      <xsl:if test="position()!=last()"> || </xsl:if>
    </xsl:for-each>
  </xsl:template>
  
  <xsl:template match="mml:apply/mml:apply[mml:or]">
    <xsl:text>(</xsl:text>
    <xsl:for-each select="*[position()&gt;1]">
      <xsl:apply-templates select="."/>
      <xsl:if test="position()!=last()"> || </xsl:if>
    </xsl:for-each>
    <xsl:text>)</xsl:text>
  </xsl:template>

  <!-- xor -->
  <xsl:template match="mml:apply[mml:xor]">
    <xsl:for-each select="*[position()&gt;1]">
      <xsl:apply-templates select="."/>
      <xsl:if test="position()!=last()"> xor </xsl:if>
    </xsl:for-each>
  </xsl:template>
  
  <xsl:template match="mml:apply/mml:apply[mml:xor]">
    <xsl:text>(</xsl:text>
    <xsl:for-each select="*[position()&gt;1]">
      <xsl:apply-templates select="."/>
      <xsl:if test="position()!=last()"> xor </xsl:if>
    </xsl:for-each>
    <xsl:text>)</xsl:text>
  </xsl:template>

  <!-- not-->
  <xsl:template match="mml:apply[mml:not]">
    <xsl:text>!</xsl:text>
    <xsl:apply-templates select="*[position()=2]"/>
  </xsl:template>

  <xsl:template match="mml:apply/mml:apply[mml:not]">
    <xsl:text>(!</xsl:text>
    <xsl:apply-templates select="*[position()=2]"/>
    <xsl:text>)</xsl:text>
  </xsl:template>

  <!-- lt -->
  <xsl:template match="mml:apply[mml:lt]">
    <xsl:text>(</xsl:text>
    <xsl:for-each select="*[position()&gt;1]">
      <xsl:apply-templates select="."/>
      <xsl:if test="position()!=last()"> &lt; </xsl:if>
    </xsl:for-each>
    <xsl:text>)</xsl:text>
  </xsl:template>

  <!-- leq -->
  <xsl:template match="mml:apply[mml:leq]">
    <xsl:for-each select="*[position()&gt;1]">
      <xsl:apply-templates select="."/>
      <xsl:if test="position()!=last()"> &lt;= </xsl:if>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="mml:apply/mml:apply[mml:leq]">
    <xsl:text>(</xsl:text>
    <xsl:for-each select="*[position()&gt;1]">
      <xsl:apply-templates select="."/>
      <xsl:if test="position()!=last()"> &lt;= </xsl:if>
    </xsl:for-each>
    <xsl:text>)</xsl:text>
  </xsl:template>

  <!-- gt -->
  <xsl:template match="mml:apply[mml:gt]">
    <xsl:for-each select="*[position()&gt;1]">
      <xsl:apply-templates select="."/>
      <xsl:if test="position()!=last()"> &gt; </xsl:if>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="mml:apply/mml:apply[mml:gt]">
    <xsl:text>(</xsl:text>
    <xsl:for-each select="*[position()&gt;1]">
      <xsl:apply-templates select="."/>
      <xsl:if test="position()!=last()"> &gt; </xsl:if>
    </xsl:for-each>
    <xsl:text>)</xsl:text>
  </xsl:template>

  <!-- geq -->
  <xsl:template match="mml:apply[mml:geq]">
    <xsl:for-each select="*[position()&gt;1]">
      <xsl:apply-templates select="."/>
      <xsl:if test="position()!=last()"> &gt;= </xsl:if>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="mml:apply/mml:apply[mml:geq]">
    <xsl:text>(</xsl:text>
    <xsl:for-each select="*[position()&gt;1]">
      <xsl:apply-templates select="."/>
      <xsl:if test="position()!=last()"> &gt;= </xsl:if>
    </xsl:for-each>
    <xsl:text>)</xsl:text>
  </xsl:template>

  <!-- eq -->
  <xsl:template match="mml:apply[mml:eq]">
    <xsl:for-each select="*[position()&gt;1]">
      <xsl:apply-templates select="."/>
      <xsl:if test="position()!=last()"> == </xsl:if>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="mml:apply/mml:apply[mml:eq]">
    <xsl:text>(</xsl:text>
    <xsl:for-each select="*[position()&gt;1]">
      <xsl:apply-templates select="."/>
      <xsl:if test="position()!=last()"> == </xsl:if>
    </xsl:for-each>
    <xsl:text>)</xsl:text>
  </xsl:template>

  <!-- neq -->
  <xsl:template match="mml:apply[mml:neq]">
    <xsl:for-each select="*[position()&gt;1]">
      <xsl:apply-templates select="."/>
      <xsl:if test="position()!=last()"> != </xsl:if>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="mml:apply/mml:apply[mml:neq]">
    <xsl:text>(</xsl:text>
    <xsl:for-each select="*[position()&gt;1]">
      <xsl:apply-templates select="."/>
      <xsl:if test="position()!=last()"> != </xsl:if>
    </xsl:for-each>
    <xsl:text>)</xsl:text>
  </xsl:template>

  <!-- <ci> -->
  <xsl:template match="mml:ci">
    <xsl:value-of select="normalize-space(text())"/>
    <xsl:if test="exsl:node-set($reserved)/*[normalize-space(current()/text())=text()]">_</xsl:if>
  </xsl:template>

  <!-- <true/> -->
  <xsl:template match="mml:true">
    <xsl:text>true</xsl:text>
  </xsl:template>

  <!-- <false/> -->
  <xsl:template match="mml:false">
    <xsl:text>false</xsl:text>
  </xsl:template>

  <!-- <cn> -->
  <xsl:template match="mml:cn">
    <xsl:value-of select="normalize-space(text()[1])"/>
  </xsl:template>

  <xsl:template match="mml:apply/mml:cn[number(text()[1]) &lt; 0]">
    <xsl:text>(</xsl:text>
    <xsl:value-of select="normalize-space(text()[1])"/>
    <xsl:text>)</xsl:text>
  </xsl:template>

  <xsl:template match="mml:cn[@type='rational']">
    <xsl:value-of select="normalize-space(text()[1])"/>
    <xsl:text>/</xsl:text>
    <xsl:value-of select="normalize-space(text()[2])"/>
  </xsl:template>
  
  <xsl:template match="mml:apply/mml:cn[@type='rational']">
    <xsl:text>(</xsl:text>
    <xsl:value-of select="normalize-space(text()[1])"/>
    <xsl:text>/</xsl:text>
    <xsl:value-of select="normalize-space(text()[2])"/>
    <xsl:text>)</xsl:text>
  </xsl:template>

  <xsl:template match="mml:cn[@type='e-notation']">
    <xsl:value-of select="normalize-space(text()[1])"/>
    <xsl:text>e</xsl:text>
    <xsl:value-of select="normalize-space(text()[2])"/>
  </xsl:template>
  
  <xsl:template match="mml:apply/mml:cn[number(text()[1]) &lt; 0]">
    <xsl:text>(</xsl:text>
    <xsl:value-of select="normalize-space(text()[1])"/>
    <xsl:text>e</xsl:text>
    <xsl:value-of select="normalize-space(text()[2])"/>
    <xsl:text>)</xsl:text>
  </xsl:template>

  <xsl:template match="mml:csymbol[@definitionURL='http://www.sbml.org/sbml/symbols/time']">
    <xsl:text>time</xsl:text>
  </xsl:template>

  <xsl:template match="mml:pi">
    <xsl:text>pi</xsl:text>
  </xsl:template>

  <xsl:template match="mml:exponentiale">
    <xsl:text>e</xsl:text>
  </xsl:template>

  <xsl:template match="mml:infinity">
    <xsl:text>Infinity</xsl:text>
  </xsl:template>

  <xsl:template match="mml:notanumber">
    <xsl:text>NaN</xsl:text>
  </xsl:template>

<!-- END MathML -->

</xsl:stylesheet>
