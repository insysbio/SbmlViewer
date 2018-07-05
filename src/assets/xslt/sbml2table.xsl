<?xml version="1.0" encoding="UTF-8"?>
<!--
Copyright 2016-2017 Institute for Systems Biology Moscow

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
Description: Creating representation of whole sbml in table format
modes:
  - table
  - reactionFormula
  - idOrName
  - unitFormula/unitFormulaScale
  - link/no-link
  - element

Author: Evgeny Metelkin
Copyright: InSysBio LLC, 2016-2017
Last modification: 2017-06-15

Project-page: http://sv.insysbio.ru
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
  exclude-result-prefixes="l1v1 l1v2 l1v3 l1v4 l1v5">

  <!-- GLOBAL KEYS -->
  <xsl:key name="idKey" match="*" use="@id"/>
  <xsl:key name="variableKey" match="*" use="@variable"/>

  <!-- PARAMETERS -->
  <xsl:param name="useNames">false</xsl:param> <!-- use names instead of id in equations -->
  <xsl:param name="correctMathml">false</xsl:param> <!-- use correction in MathML (for simbio) always on currently-->
  <xsl:param name="equationsOff">false</xsl:param> <!-- do not show equations -->

  <!-- top -->
  <xsl:template match="/">
    <div class="w3-container">
      <xsl:apply-templates mode="table"/>
    </div>
  </xsl:template>

  <!-- SBML -->
  <xsl:template match="*[local-name()='sbml']" mode="table">
      <h1 class="w3-tooltip">SBML level <xsl:value-of select="@level"/> version <xsl:value-of select="@version"/></h1>

      <xsl:apply-templates select="*[local-name()='notes']" mode="element"/>
      <xsl:apply-templates select="*[local-name()='annotation']" mode="element"/>
      <xsl:apply-templates select="*[local-name()='model']" mode="table"/>
  </xsl:template>

  <!-- model -->
  <xsl:template match="*[local-name()='model']" mode="table">
    <h2>model:</h2>
    <xsl:apply-templates select="@*" mode="element"/>
    <xsl:apply-templates select="*[local-name()='notes']" mode="element"/>
    <xsl:apply-templates select="*[local-name()='annotation']" mode="element"/>
    <xsl:apply-templates select="*[contains(local-name(), 'listOf')]" mode="table"/>
  </xsl:template>

  <xsl:template match="*[local-name()='annotation']" mode="element">
   <p><strong>annotation:</strong> =presented=</p>
  </xsl:template>

  <!-- Notes -->
  <xsl:template match="*[local-name()='notes']" mode="element">
   <p><strong>notes:</strong></p>
   <div class="w3-container w3-pale-blue" style="max-width:80%;min-width:300px">
    <xsl:copy-of select="node()"/>
   </div>
  </xsl:template>

  <xsl:template match="*[local-name()='notes' and xhtml:body]" mode="element">
   <p><strong>notes:</strong></p>
   <div class="w3-container w3-pale-blue" style="max-width:80%;min-width:300px">
    <xsl:copy-of select="xhtml:body/node()"/>
   </div>
  </xsl:template>

  <xsl:template match="*[local-name()='notes' and xhtml:html[xhtml:body]]" mode="element">
   <p><strong>notes:</strong></p>
   <div class="w3-container w3-pale-blue" style="max-width:80%;min-width:300px">
    <xsl:copy-of select="xhtml:html/xhtml:body/node()"/>
   </div>
  </xsl:template>

  <xsl:template match="@*" mode="element">
    <p><strong><xsl:value-of select="local-name()"/></strong>: <xsl:value-of select="."/></p>
  </xsl:template>

  <!-- id with notes -->
    <xsl:template match="@id" mode="link">
      <span style="color: blue; text-decoration: underline; cursor: pointer;" class='annotationTarget'>
      <xsl:attribute name="id"><xsl:value-of select="."/></xsl:attribute>
      <xsl:value-of select="."/>
      </span>
       <div
         style="position:absolute; left:50%; bottom:95%; border-radius:6px; padding:8px; width:300px;"
         class="w3-text w3-pale-blue">
           <xsl:apply-templates select="../*[local-name()='notes']" mode="table"/>
           <xsl:apply-templates select="../*[local-name()='annotation']" mode="element"/>
         </div>
    </xsl:template>

    <xsl:template match="@id" mode="no-link">
      <span style="color: blue;">
      <xsl:attribute name="id"><xsl:value-of select="."/></xsl:attribute>
      <xsl:value-of select="."/>
      </span>
       <div
         style="position:absolute; left:50%; bottom:95%; border-radius:6px; padding:8px; width:300px;"
         class="w3-text w3-pale-blue">
           <xsl:apply-templates select="../*[local-name()='notes']" mode="table"/>
           <xsl:apply-templates select="../*[local-name()='annotation']" mode="element"/>
         </div>
    </xsl:template>

    <xsl:template match="@symbol|@variable" mode="no-link">
	  <xsl:if test="not(key('idKey',.))">
	    <span style="color:red;">
		<xsl:attribute name="id"><xsl:value-of select="."/></xsl:attribute>
		<xsl:value-of select="."/>
		</span>
      </xsl:if>
	  <xsl:if test="key('idKey',.)">
	    <span style="color: blue;">
        <xsl:attribute name="id"><xsl:value-of select="."/></xsl:attribute>
	    <xsl:apply-templates select="key('idKey',.)/@id" mode="idOrName"/>
        </span>
	  </xsl:if>

       <div
         style="position:absolute; left:50%; bottom:95%; border-radius:6px; padding:8px; width:300px;"
         class="w3-text w3-pale-blue">
           <xsl:apply-templates select="../*[local-name()='notes']" mode="table"/>
           <xsl:apply-templates select="../*[local-name()='annotation']" mode="element"/>
         </div>
    </xsl:template>

	<!-- SId object: internal ref -->
    <xsl:template match="@species|@substanceUnits|@units|@compartment|@speciesType|@compartmentType|@outside">
	  <xsl:if test="not(key('idKey',.))"><span style="color:red;"><xsl:value-of select="."/></span></xsl:if>
	  <xsl:if test="key('idKey',.)"><xsl:apply-templates select="key('idKey',.)/@id" mode="idOrName"/></xsl:if>
    </xsl:template>

    <!-- listOfFunctionDefinitions -->
    <xsl:template match="*[local-name()='listOfFunctionDefinitions']" mode="table">
      <h3>listOfFunctionDefinitions:</h3>
      <xsl:apply-templates select="@*" mode="element"/>
      <xsl:apply-templates select="*[local-name()='notes']" mode="element"/>
      <xsl:apply-templates select="*[local-name()='annotation']" mode="element"/>
      <table class="w3-table w3-striped w3-border w3-hoverable w3-card-4" style="width: auto;max-width:95%;">
      <tr class="w3-blue-grey">
        <th>id</th>
        <th><xsl:if test="*/@name">name</xsl:if></th>
        <th><xsl:if test="*/@metaid">metaid</xsl:if></th>
        <th>math</th>
      </tr>
      <xsl:apply-templates select="*[local-name()='functionDefinition']" mode="table"/>
      </table>
    </xsl:template>

    <xsl:template match="*[local-name()='functionDefinition']" mode="table">
        <tr>
          <td class="w3-tooltip"><xsl:apply-templates select="@id" mode="no-link"/></td>
          <td><xsl:value-of select="@name"/></td>
          <td class="w3-tiny"><xsl:apply-templates select="@metaid" mode="table"/></td>
          <td><xsl:apply-templates select="mml:math"/></td>
        </tr>
    </xsl:template>

    <!-- listOfUnitDefinitions -->
    <xsl:template match="*[local-name()='listOfUnitDefinitions']" mode="table">
      <h3>listOfUnitDefinitions:</h3>
      <xsl:apply-templates select="@*" mode="element"/>
      <xsl:apply-templates select="*[local-name()='notes']" mode="element"/>
      <xsl:apply-templates select="*[local-name()='annotation']" mode="element"/>
      <table class="w3-table w3-striped w3-border w3-hoverable w3-card-4" style="width: auto;max-width:95%;">
      <tr class="w3-blue-grey">
        <th>id</th>
        <th><xsl:if test="*/@name">name</xsl:if></th>
        <th><xsl:if test="*/@metaid">metaid</xsl:if></th>
        <th>listOfUnits</th>
      </tr>
      <xsl:apply-templates select="*[local-name()='unitDefinition']" mode="table"/>
      </table>
    </xsl:template>

    <xsl:template match="*[local-name()='unitDefinition']" mode="table">
        <tr>
          <td class="w3-tooltip"><xsl:apply-templates select="@id" mode="no-link"/></td>
          <td><xsl:value-of select="@name"/></td>
          <td class="w3-tiny"><xsl:apply-templates select="@metaid" mode="table"/></td>
          <td><xsl:apply-templates select="*[local-name()='listOfUnits']" mode="unitFormula"/></td>
        </tr>
    </xsl:template>

    <!-- listOfCompartmentTypes -->
    <xsl:template match="*[local-name()='listOfCompartmentTypes']" mode="table">
      <h3>listOfCompartmentTypes:</h3>
      <xsl:apply-templates select="@*" mode="element"/>
      <xsl:apply-templates select="*[local-name()='notes']" mode="element"/>
      <xsl:apply-templates select="*[local-name()='annotation']" mode="element"/>
      <table class="w3-table w3-striped w3-border w3-hoverable w3-card-4" style="width: auto;max-width:95%;">
      <tr class="w3-blue-grey"><th>id</th><th>name</th><th>metaid</th></tr>
      <xsl:apply-templates select="*[local-name()='compartmentType']" mode="table"/>
      </table>
    </xsl:template>

    <xsl:template match="*[local-name()='compartmentType']" mode="table">
        <tr>
          <td class="w3-tooltip"><xsl:apply-templates select="@id" mode="no-link"/></td>
          <td><xsl:value-of select="@name"/></td>
          <td class="w3-tiny"><xsl:value-of select="@metaid"/></td>
        </tr>
    </xsl:template>

    <!-- listOfSpeciesTypes -->
    <xsl:template match="*[local-name()='listOfSpeciesTypes']" mode="table">
      <h3>listOfSpeciesTypes:</h3>
      <xsl:apply-templates select="@*" mode="element"/>
      <xsl:apply-templates select="*[local-name()='notes']" mode="element"/>
      <xsl:apply-templates select="*[local-name()='annotation']" mode="element"/>
      <table class="w3-table w3-striped w3-border w3-hoverable w3-card-4" style="width: auto;max-width:95%;">
      <tr class="w3-blue-grey"><th>id</th><th>name</th><th>metaid</th></tr>
      <xsl:apply-templates select="*[local-name()='speciesType']" mode="table"/>
      </table>
    </xsl:template>

    <xsl:template match="*[local-name()='speciesType']" mode="table">
        <tr>
          <td class="w3-tooltip"><xsl:apply-templates select="@id" mode="no-link"/></td>
          <td><xsl:value-of select="@name"/></td>
          <td class="w3-tiny"><xsl:value-of select="@metaid"/></td>
        </tr>
    </xsl:template>

    <!-- listOfCompartments -->
    <xsl:template match="*[local-name()='listOfCompartments']" mode="table">
      <h3>listOfCompartments:</h3>
      <xsl:apply-templates select="@*" mode="element"/>
      <xsl:apply-templates select="*[local-name()='notes']" mode="element"/>
      <xsl:apply-templates select="*[local-name()='annotation']" mode="element"/>

      <table class="w3-table w3-striped w3-border w3-hoverable w3-card-4" style="width: auto;max-width:95%;">
      <tr class="w3-blue-grey">
      <th>id</th>
      <th><xsl:if test="*/@name">name</xsl:if></th>
      <th><xsl:if test="*/@metaid">metaid</xsl:if></th>
      <th><xsl:if test="*/@compartmentType">compartment<br/>Type</xsl:if></th>
      <th><xsl:if test="*/@outside">outside</xsl:if></th>
      <th><xsl:if test="*/@units">units</xsl:if></th>
      <th><xsl:if test="*/@size">size</xsl:if></th>
      </tr>
      <xsl:apply-templates select="*[local-name()='compartment']" mode="table"/>
      </table>
    </xsl:template>

    <xsl:template match="*[local-name()='compartment']" mode="table">
        <tr>
          <td class="w3-tooltip"><xsl:apply-templates select="@id" mode="link"/></td>
          <td><xsl:value-of select="@name"/></td>
          <td  class="w3-tiny"><xsl:value-of select="@metaid"/></td>
          <td><xsl:apply-templates select="@compartmentType"/></td>
          <td><xsl:apply-templates select="@outside"/></td>
          <td><xsl:apply-templates select="@units"/></td>
          <td><xsl:value-of select="@size"/></td>
        </tr>
    </xsl:template>

  <!-- listOfSpecies -->
  <xsl:template match="*[local-name()='listOfSpecies']" mode="table">
      <h3>listOfSpecies:</h3>
      <xsl:apply-templates select="@*" mode="element"/>
      <xsl:apply-templates select="*[local-name()='notes']" mode="element"/>
      <xsl:apply-templates select="*[local-name()='annotation']" mode="element"/>

      <table class="w3-table w3-striped w3-border w3-hoverable w3-card-4"  style="width: auto; max-width:95%;">
      <tr class="w3-blue-grey">
      <th>id</th>
      <th><xsl:if test="*/@name">name</xsl:if></th>
      <th><xsl:if test="*/@metaid">metaid</xsl:if></th>
      <th><xsl:if test="*/@speciesType">speciesType</xsl:if></th>
      <th><xsl:if test="*/@substanceUnits">substance<br/>Units</xsl:if></th>
      <th><xsl:if test="*/@hasOnlySubstanceUnits">hasOnly<br/>Substance<br/>Units</xsl:if></th>
      <th><xsl:if test="*/@initialConcentration">initial<br/>Concentration</xsl:if></th>
      <th><xsl:if test="*/@initialAmount">initial<br/>Amount</xsl:if></th>
      <th><xsl:if test="*/@boundaryCondition">boundary<br/>Condition</xsl:if></th>
      <th><xsl:if test="*/@compartment">compartment</xsl:if></th>
      <th><xsl:if test="*/@charge">charge</xsl:if></th>
      </tr>
        <xsl:apply-templates select="*[local-name()='species']" mode="table"/>
      </table>
  </xsl:template>

    <xsl:template match="*[local-name()='species']" mode="table">
        <tr>
          <td class="w3-tooltip"><xsl:apply-templates select="@id" mode="link"/></td>
          <td><xsl:value-of select="@name"/></td>
          <td class="w3-tiny"><xsl:value-of select="@metaid"/></td>
          <td><xsl:apply-templates select="@speciesType"/></td>
          <td><xsl:apply-templates select="@substanceUnits"/></td>
          <td><xsl:value-of select="@hasOnlySubstanceUnits"/></td>
          <td><xsl:value-of select="@initialConcentration"/></td>
          <td><xsl:value-of select="@initialAmount"/></td>
          <td><xsl:value-of select="@boundaryCondition"/></td>
          <td><xsl:apply-templates select="@compartment"/></td>
          <td><xsl:value-of select="@charge"/></td>
        </tr>
    </xsl:template>

  <!-- listOfParameters -->
  <xsl:template match="*[local-name()='listOfParameters']" mode="table">
      <h3>listOfParameters:</h3>
      <xsl:apply-templates select="@*" mode="element"/>
      <xsl:apply-templates select="*[local-name()='notes']" mode="element"/>
      <xsl:apply-templates select="*[local-name()='annotation']" mode="element"/>

      <table class="w3-table w3-striped w3-border w3-hoverable w3-card-4" style="width:auto; max-width:95%;">
      <tr class="w3-blue-grey">
      <th>id</th>
      <th><xsl:if test="*/@name">name</xsl:if></th>
      <th><xsl:if test="*/@metaid">metaid</xsl:if></th>
      <th><xsl:if test="*/@units">units</xsl:if></th>
      <th><xsl:if test="*/@value">value</xsl:if></th>
      </tr>
        <xsl:apply-templates select="*[local-name()='parameter']" mode="table"/>
      </table>
  </xsl:template>

  <xsl:template match="*[local-name()='parameter']" mode="table">
        <tr>
          <td class="w3-tooltip"><xsl:apply-templates select="@id" mode="link"/></td>
          <td><xsl:value-of select="@name"/></td>
          <td class="w3-tiny"><xsl:value-of select="@metaid"/></td>
          <td><xsl:apply-templates select="@units"/></td>
          <td>
          <xsl:if test="not(key('variableKey', @id))"><xsl:value-of select="@value"/></xsl:if>
          <!--<xsl:apply-templates select="key('variableKey', @id)/mml:math"/>-->
          </td>
        </tr>
  </xsl:template>

  <!-- listOfInitialAssignments annotation -->
  <xsl:template match="*[local-name()='listOfInitialAssignments']" mode="table">
      <h3>listOfInitialAssignments:</h3>
      <xsl:apply-templates select="@*" mode="element"/>
      <xsl:apply-templates select="*[local-name()='notes']" mode="element"/>
      <xsl:apply-templates select="*[local-name()='annotation']" mode="element"/>

      <table class="w3-table w3-striped w3-border w3-hoverable w3-card-4"  style="width: auto; max-width:95%;">
      <tr class="w3-blue-grey">
      <th>symbol</th>
      <th><xsl:if test="*/@metaid">metaid</xsl:if></th>
      <th>math:</th>
      </tr>
        <xsl:apply-templates select="*[local-name()='initialAssignment']" mode="table"/>
      </table>
  </xsl:template>

  <xsl:template match="*[local-name()='initialAssignment']" mode="table">
        <tr>
          <td class="w3-tooltip"><xsl:apply-templates select="@symbol" mode="no-link"/></td>
          <td class="w3-tiny"><xsl:value-of select="@metaid"/></td>
          <td><xsl:apply-templates select="mml:math"/></td>
        </tr>
  </xsl:template>

  <!-- listOfConstraints annotation -->
  <xsl:template match="*[local-name()='listOfConstraints']" mode="table">
      <h3>listOfConstraints:</h3>
      <xsl:apply-templates select="@*" mode="element"/>
      <xsl:apply-templates select="*[local-name()='notes']" mode="element"/>
      <xsl:apply-templates select="*[local-name()='annotation']" mode="element"/>

      <table class="w3-table w3-striped w3-border w3-hoverable w3-card-4"  style="width: auto; max-width:95%;">
      <tr class="w3-blue-grey">
        <th><xsl:if test="*/@metaid">metaid</xsl:if></th>
        <th>message</th>
        <th>math:</th>
      </tr>
        <xsl:apply-templates select="*[local-name()='constraint']" mode="table"/>
      </table>
  </xsl:template>

  <xsl:template match="*[local-name()='constraint']" mode="table">
        <tr>
          <td class="w3-tiny"><xsl:value-of select="@metaid"/></td>
          <td><xsl:apply-templates select="*[local-name()='message']" mode="table"/></td>
          <td><xsl:apply-templates select="mml:math"/></td>
        </tr>
  </xsl:template>

  <!-- listOfRules annotation -->
  <xsl:template match="*[local-name()='listOfRules']" mode="table">
      <h3>listOfRules:</h3>
      <xsl:apply-templates select="@*" mode="element"/>
      <xsl:apply-templates select="*[local-name()='notes']" mode="element"/>
      <xsl:apply-templates select="*[local-name()='annotation']" mode="element"/>

      <table class="w3-table w3-striped w3-border w3-hoverable w3-card-4"  style="width: auto; max-width:95%;">
      <tr class="w3-blue-grey">
	    <th>type</th>
		<th>variable</th>
		<th><xsl:if test="*/@metaid">metaid</xsl:if></th>
		<th>math:</th>
	  </tr>
      <xsl:apply-templates select="*[local-name()='assignmentRule'] | *[local-name()='algebraicRule'] | *[local-name()='rateRule']" mode="table"/>
      </table>
  </xsl:template>

  <xsl:template match="
    *[local-name()='assignmentRule'] |
    *[local-name()='algebraicRule'] |
    *[local-name()='rateRule']
    " mode="table">
        <tr>
          <td><xsl:value-of select="local-name()"/></td>
          <td class="w3-tooltip"><xsl:apply-templates select="@variable" mode="no-link"/></td>
          <td class="w3-tiny"><xsl:value-of select="@metaid"/></td>
          <td><xsl:apply-templates select="mml:math"/></td>
        </tr>
  </xsl:template>

  <!-- listOfReactions annotation -->
  <xsl:template match="*[local-name()='listOfReactions']" mode="table">
      <h3>listOfReactions:</h3>
      <xsl:apply-templates select="@*" mode="element"/>
      <xsl:apply-templates select="*[local-name()='notes']" mode="element"/>
      <xsl:apply-templates select="*[local-name()='annotation']" mode="element"/>

      <table class="w3-table w3-striped w3-border w3-hoverable w3-card-4" style="width: auto; max-width:95%;">
      <tr class="w3-blue-grey">
        <th>id</th>
        <th><xsl:if test="*/@name">name</xsl:if></th>
        <th><xsl:if test="*/@metaid">metaid</xsl:if></th>
        <th>reaction formula:</th>
        <th>math:</th>
      </tr>

        <xsl:apply-templates select="*[local-name()='reaction']" mode="table"/>
      </table>

      <!-- <h3>listOfReactions (local parameters):</h3> --> <!-- add later-->
  </xsl:template>

  <xsl:template match="*[local-name()='reaction']" mode="table">
        <tr>
          <td class="w3-tooltip"><xsl:apply-templates select="@id" mode="link"/></td>
          <td><xsl:value-of select="@name"/></td>
          <td class="w3-tiny"><xsl:value-of select="@metaid"/></td>
          <td><xsl:apply-templates select="." mode="reactionFormula"/></td>
          <td><xsl:apply-templates select="*[local-name()='kineticLaw']/mml:math"/></td>
        </tr>

        <xsl:if test="*[local-name()='kineticLaw']/*/*[local-name()='parameter']">
        <tr>
        <td colspan="10" style="font-size:67%;"><xsl:apply-templates select="*[local-name()='kineticLaw']/*[local-name()='listOfParameters']" mode="table"/></td>
        </tr>
        </xsl:if>
  </xsl:template>

  <!-- listOfEvents annotation -->
  <xsl:template match="*[local-name()='listOfEvents']" mode="table">
      <h3>listOfEvents:</h3>
      <xsl:apply-templates select="@*" mode="element"/>
      <xsl:apply-templates select="*[local-name()='notes']" mode="element"/>
      <xsl:apply-templates select="*[local-name()='annotation']" mode="element"/>

      <table class="w3-table w3-striped w3-border w3-hoverable w3-card-4"  style="width: auto; max-width:95%;">
      <tr class="w3-blue-grey">
        <th>id</th>
        <th><xsl:if test="*/@name">name</xsl:if></th>
        <th><xsl:if test="*/@metaid">metaid</xsl:if></th>
        <th><xsl:if test="*/@useValuesFromTriggerTime">useValuesFrom<br/>TriggerTime</xsl:if></th>
        <th>trigger</th>
        <th>delay</th>
        <th>listOfEvent<br/>Assignments</th>
      </tr>
      <xsl:apply-templates select="*[local-name()='event']" mode="table"/>
      </table>
  </xsl:template>

  <xsl:template match="*[local-name()='event']" mode="table">
        <tr>
          <td class="w3-tooltip"><xsl:apply-templates select="@id" mode="no-link"/></td>
          <td><xsl:value-of select="@name"/></td>
          <td class="w3-tiny"><xsl:value-of select="@metaid"/></td>
          <td><xsl:value-of select="@useValuesFromTriggerTime"/></td>
          <td><xsl:apply-templates select="*[local-name()='trigger']" mode="table"/></td>
          <td><xsl:apply-templates select="*[local-name()='delay']" mode="table"/></td>
          <td><xsl:apply-templates select="*[local-name()='listOfEventAssignments']" mode="table"/></td>
        </tr>
  </xsl:template>

  <xsl:template match="*[local-name()='trigger']" mode="table">
    <xsl:apply-templates select="mml:math"/>
  </xsl:template>

  <xsl:template match="*[local-name()='delay']" mode="table">
    <xsl:apply-templates select="mml:math"/>
  </xsl:template>

  <!-- listOfEventAssignments annotation -->
  <xsl:template match="*[local-name()='listOfEventAssignments']" mode="table">
    <b><xsl:value-of select="@metaid"/></b>
      <table class="w3-table w3-striped w3-border"  style="width: auto; max-width:95%;">
      <tr>
      <th>variable</th>
      <th><xsl:if test="*/@metaid">metaid</xsl:if></th>
      <th>math:</th>
      </tr>
        <xsl:apply-templates select="*[local-name()='eventAssignment']" mode="table"/>
      </table>
  </xsl:template>

  <xsl:template match="*[local-name()='eventAssignment']" mode="table">
        <tr>
          <td class="w3-tooltip"><xsl:apply-templates select="@variable" mode="no-link"/></td>
          <td class="w3-tiny"><xsl:value-of select="@metaid"/></td>
          <td><xsl:apply-templates select="mml:math"/></td>
        </tr>
  </xsl:template>

  <xsl:template match="*[local-name()='unitDefinition']/@name" mode="table">
    <xsl:value-of select="."/>
  </xsl:template>

  <xsl:template match="*[local-name()='notes']" mode="table">
    <xsl:copy-of select="node()"/>
  </xsl:template>

  <!-- message type: just copy -->
  <xsl:template match="*[local-name()='message']" mode="table">
    <xsl:copy-of select="node()"/>
  </xsl:template>

  <!-- do nothing if nothing to output-->
  <xsl:template match="*" mode="table">
    = ??? <xsl:value-of select="local-name()"/>=
  </xsl:template>

  <!-- do not show some elements -->
  <xsl:template match="
    *[local-name()='annotation']
    " mode="table"/>
<!-- END OF table mode -->

<!-- BEGIN OF unitFormula/unitFormulaScale mode -->

    <xsl:template match="l2v2:listOfUnits | l2v3:listOfUnits | l2v4:listOfUnits| l2v5:listOfUnits" mode="unitFormula">
      <xsl:element name="math" namespace="http://www.w3.org/1998/Math/MathML">
        <xsl:element name="apply" namespace="http://www.w3.org/1998/Math/MathML">
          <xsl:element name="times" namespace="http://www.w3.org/1998/Math/MathML"/>
          <xsl:apply-templates select="*[local-name()='unit']" mode="unitFormula"/>
        </xsl:element>
      </xsl:element>
    </xsl:template>

    <xsl:template match="*[local-name()='unit' and @exponent!='1']" mode="unitFormula">
      <xsl:element name="apply" namespace="http://www.w3.org/1998/Math/MathML">
        <xsl:element name="power" namespace="http://www.w3.org/1998/Math/MathML"/>
        <xsl:element name="apply" namespace="http://www.w3.org/1998/Math/MathML">
          <xsl:element name="times" namespace="http://www.w3.org/1998/Math/MathML"/>
          <xsl:apply-templates select="." mode="unitFormulaScale"/>
          <xsl:element name="ci" namespace="http://www.w3.org/1998/Math/MathML"><xsl:value-of select="@kind"/></xsl:element>
        </xsl:element>
        <xsl:element name="cn" namespace="http://www.w3.org/1998/Math/MathML"><xsl:value-of select="@exponent"/></xsl:element>
      </xsl:element>
    </xsl:template>

    <xsl:template match="*[local-name()='unit' and not(@exponent!='1')]" mode="unitFormula">
        <xsl:element name="apply" namespace="http://www.w3.org/1998/Math/MathML">
          <xsl:element name="times" namespace="http://www.w3.org/1998/Math/MathML"/>
          <xsl:apply-templates select="." mode="unitFormulaScale"/>
          <xsl:element name="ci" namespace="http://www.w3.org/1998/Math/MathML"><xsl:value-of select="@kind"/></xsl:element>
        </xsl:element>
    </xsl:template>

    <xsl:template match="*[local-name()='unit' and not(@scale!='0')]" mode="unitFormulaScale">
      <xsl:element name="cn" namespace="http://www.w3.org/1998/Math/MathML">
        <xsl:value-of select="@multiplier"/>
      </xsl:element>
    </xsl:template>

    <xsl:template match="*[local-name()='unit' and @scale!='0' and @multiplier!='1']" mode="unitFormulaScale">
      <xsl:element name="cn" namespace="http://www.w3.org/1998/Math/MathML">
        <xsl:value-of select="@multiplier"/>e<xsl:value-of select="@scale"/>
      </xsl:element>
    </xsl:template>

    <xsl:template match="*[local-name()='unit' and @scale!='0' and not(@multiplier!='1')]" mode="unitFormulaScale">
      <xsl:element name="cn" namespace="http://www.w3.org/1998/Math/MathML">
        1e<xsl:value-of select="@scale"/>
      </xsl:element>
    </xsl:template>

    <xsl:template match="*[local-name()='unit' and not(@scale!='0') and not(@multiplier!='1') ]" mode="unitFormulaScale" />

    <xsl:template match="l2v1:listOfUnits" mode="unitFormula">
      <span style="color: red;"> = not supported for l2v1 =</span>
    </xsl:template>
<!-- END OF unitFormula/unitFormulaScale mode -->

<!-- BEGIN OF idOrName mode -->
  <xsl:template match="@id" mode="idOrName">
      <xsl:if test="$useNames='true' and count(./../@name)>0">'<xsl:value-of select="./../@name"/>'</xsl:if>  <!-- for simbio only-->
      <xsl:if test="$useNames='true' and count(./../@name)=0">'=unnamed='</xsl:if>
      <xsl:if test="not($useNames='true')"><xsl:value-of select="."/></xsl:if>
  </xsl:template>
<!-- END OF idOrName mode -->

<!-- BEGIN OF reactionFormula mode -->
  <xsl:template match="
    *[local-name()='reaction']
    " mode="reactionFormula">
    <xsl:if test="count(*[local-name()='listOfReactants']/*[local-name()='speciesReference'])=0">&#8709;</xsl:if>
    <xsl:apply-templates select="*[local-name()='listOfReactants']" mode="reactionFormula"/>
    <xsl:if test="@reversible='false' and @fast='true'"> &#8594; </xsl:if>
    <xsl:if test="not(@reversible='false') and @fast='true'"> &#8596; </xsl:if>
    <xsl:if test="@reversible='false' and not(@fast='true')"> &#8658; </xsl:if>
    <xsl:if test="not(@reversible='false') and not(@fast='true')"> &#8660; </xsl:if>
    <xsl:if test="count(*[local-name()='listOfProducts']/*[local-name()='speciesReference'])=0">&#8709;</xsl:if>
    <xsl:apply-templates select="*[local-name()='listOfProducts']" mode="reactionFormula"/>
    <xsl:apply-templates select="*[local-name()='listOfModifiers']" mode="reactionFormula"/>
  </xsl:template>

  <!-- listOfReactants / listOfProducts-->
  <xsl:template match="
    *[local-name()='listOfReactants'] |
    *[local-name()='listOfProducts']
    " mode="reactionFormula">
    <xsl:for-each select="*[local-name()='speciesReference']">
      <xsl:if test="@stoichiometry!='1'">
        <xsl:value-of select="@stoichiometry"/> &#215;
      </xsl:if>
	  <xsl:apply-templates select="@species"/>
      <xsl:if test="position()!=last()">+</xsl:if>
    </xsl:for-each>
  </xsl:template>

  <!-- listOfModifiers-->
  <xsl:template match="
    *[local-name()='listOfModifiers']
    " mode="reactionFormula">
    <xsl:if test="count(*[local-name()='modifierSpeciesReference'])>0"> ~ </xsl:if>
    <xsl:for-each select="*[local-name()='modifierSpeciesReference']">
	  <xsl:apply-templates select="@species"/>
      <xsl:if test="position()!=last()">, </xsl:if>
    </xsl:for-each>
  </xsl:template>
<!-- END OF reactionFormula mode -->

<!-- BEGIN OF mml: part, =TO DO= include $correctMathml switcher, correction of SimBiology specific functions -->
  <!-- correct for max function -->
  <xsl:template match="mml:apply[*[1][self::mml:ci][normalize-space(text())='max'][following-sibling::mml:ci]]">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:element name="max" namespace="http://www.w3.org/1998/Math/MathML"/>
      <xsl:apply-templates select="*[position()&gt;1]"/>
    </xsl:copy>
  </xsl:template>

  <!-- exclude vertcat inside max -->
  <xsl:template match="mml:apply[*[1][self::mml:ci][normalize-space(text())='max'][following-sibling::mml:apply]]">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:element name="max" namespace="http://www.w3.org/1998/Math/MathML"/>
      <xsl:apply-templates select="*[2]/*[position()&gt;1]"/>
    </xsl:copy>
  </xsl:template>

  <!-- correct for min function -->
  <xsl:template match="mml:apply[*[1][self::mml:ci][normalize-space(text())='min'][following-sibling::mml:ci]]">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:element name="min" namespace="http://www.w3.org/1998/Math/MathML"/>
      <xsl:apply-templates select="*[position()&gt;1]"/>
    </xsl:copy>
  </xsl:template>

  <!-- exclude vertcat inside min -->
  <xsl:template match="mml:apply[*[1][self::mml:ci][normalize-space(text())='min'][following-sibling::mml:apply]]">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:element name="min" namespace="http://www.w3.org/1998/Math/MathML"/>
      <xsl:apply-templates select="*[2]/*[position()&gt;1]"/>
    </xsl:copy>
  </xsl:template>

  <!-- use id or names for equations and normalize space -->
  <xsl:template match="mml:ci">
    <xsl:element name="ci" namespace="http://www.w3.org/1998/Math/MathML">
      <xsl:if test="$useNames='true' and key('idKey',normalize-space(text()))/@name">'<xsl:value-of select="key('idKey',normalize-space(text()))/@name"/>'</xsl:if>
      <xsl:if test="$useNames='true' and not(key('idKey',normalize-space(text()))/@name)">'=unnamed='</xsl:if>
      <xsl:if test="not($useNames='true')"><xsl:value-of select="normalize-space(text())"/></xsl:if>
    </xsl:element>
  </xsl:template>

  <!-- adaptation of e-notation for MathJax -->
  <xsl:template match="mml:cn[@type='e-notation']">
    <xsl:element name="cn" namespace="http://www.w3.org/1998/Math/MathML">
      <xsl:copy-of select="normalize-space(text()[1])"/><xsl:if test="normalize-space(text()[2])!='0'">e<xsl:copy-of select="normalize-space(text()[2])"/>
      </xsl:if>
    </xsl:element>
  </xsl:template>

  <!-- adaptation of integer for MathJax -->
  <xsl:template match="mml:cn[@type='integer']">
    <xsl:element name="cn" namespace="http://www.w3.org/1998/Math/MathML">
      <xsl:copy-of select="normalize-space(text())"/>
    </xsl:element>
  </xsl:template>

  <!-- just copy mml or not -->
  <xsl:template match="mml:math">
    <xsl:if test="$equationsOff='true'"><i style="color:red;">Equations are hidden</i></xsl:if>
    <xsl:if test="not($equationsOff='true')">
      <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates/>
    </xsl:copy>
    </xsl:if>
  </xsl:template>

  <xsl:template match="mml:*">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="mml:lambda">
   <xsl:element name="apply" namespace="http://www.w3.org/1998/Math/MathML">
    <xsl:element name="equivalent" namespace="http://www.w3.org/1998/Math/MathML"/>
    <xsl:element name="apply" namespace="http://www.w3.org/1998/Math/MathML">
      <xsl:element name="ci" namespace="http://www.w3.org/1998/Math/MathML">f</xsl:element>
      <xsl:copy-of select="mml:bvar/mml:*"/>
    </xsl:element>
    <xsl:copy-of select="*[local-name()!='bvar']"/>

   </xsl:element>
  </xsl:template>
<!-- END OF mml: part -->
</xsl:stylesheet>
