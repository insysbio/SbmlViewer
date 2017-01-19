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
  - idOrName/idOrNamePlus
  - unitFormula/unitFormulaScale

Author: Evgeny Metelkin
Copyright: Institute for Systems Biology, Moscow
Last modification: 2017-01-15

Project-page: http://sbmlviewer.insilicobio.ru
-->
<xsl:stylesheet version="1.0" 
  xmlns="http://www.w3.org/1999/xhtml"
  xmlns:l2v1="http://www.sbml.org/sbml/level2/version1"
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
  
<!-- BEGIN OF reactionFormula mode -->
  <!-- SBML -->
  <xsl:template match="*[local-name()='sbml']" mode="table">
      <h1 class="w3-tooltip">SBML level <xsl:value-of select="@level"/> version <xsl:value-of select="@version"/>
      <div style="
         position:absolute; background:#eee; border-radius:6px; padding:8px;
         " class="w3-text">
           <xsl:apply-templates select="*[local-name()='notes']" mode="table"/>
      </div></h1>
      <xsl:apply-templates select="*[local-name()='model']" mode="table"/>
  </xsl:template>
  
  <!-- model -->
  <xsl:template match="*[local-name()='model']" mode="table">
      <xsl:apply-templates mode="table"/>
  </xsl:template>
  
  <!-- id with notes -->
  <xsl:template match="@id" mode="table">
      <span style="color: blue; text-decoration: underline; cursor: pointer;" onclick="w3_open(event)">
      <xsl:attribute name="id"><xsl:value-of select="."/></xsl:attribute>
      <xsl:value-of select="."/>
      </span>
       <div 
         style="position:absolute; left:50%; bottom:90%; border-radius:6px; padding:8px; width:300px;"
         class="w3-text w3-pale-blue">
           <xsl:apply-templates select="../*[local-name()='notes']" mode="table"/>
         </div>
    </xsl:template>
    
    <!-- listOfFunctionDefinitions -->
    <xsl:template match="*[local-name()='listOfFunctionDefinitions']" mode="table">
      <h3>listOfFunctionDefinitions:</h3>
      <table class="w3-table w3-striped w3-border w3-hoverable w3-card-4" style="width: auto;max-width:90%;">
      <tr class="w3-blue-grey"><th>id</th><th>name</th><th>metaid</th><th>math</th></tr>
      <xsl:apply-templates select="*[local-name()='functionDefinition']" mode="table"/>
      </table>
    </xsl:template>
    
    <xsl:template match="*[local-name()='functionDefinition']" mode="table">
        <tr>
          <td class="w3-tooltip"><xsl:apply-templates select="@id" mode="table"/></td>
          <td><xsl:value-of select="@name"/></td>
          <td><xsl:apply-templates select="@metaid" mode="table"/></td>
          <td><xsl:apply-templates select="mml:math"/></td>
        </tr>
    </xsl:template>
    
    <!-- listOfUnitDefinitions -->
    <xsl:template match="*[local-name()='listOfUnitDefinitions']" mode="table">
      <h3>listOfUnitDefinitions:</h3>
      <table class="w3-table w3-striped w3-border w3-hoverable w3-card-4" style="width: auto;max-width:90%;">
      <tr class="w3-blue-grey"><th>id</th><th>name</th><th>metaid</th><th>listOfUnits</th></tr>
      <xsl:apply-templates select="*[local-name()='unitDefinition']" mode="table"/>
      </table>
    </xsl:template>
    
    <xsl:template match="*[local-name()='unitDefinition']" mode="table">
        <tr>
          <td class="w3-tooltip"><xsl:apply-templates select="@id" mode="table"/></td>
          <td><xsl:value-of select="@name"/></td>
          <td><xsl:apply-templates select="@metaid" mode="table"/></td>
          <td><xsl:apply-templates select="*[local-name()='listOfUnits']" mode="unitFormula"/></td>
        </tr>
    </xsl:template>
    
    <!-- listOfCompartmentTypes -->
    <xsl:template match="*[local-name()='listOfCompartmentTypes']" mode="table">
      <h3>listOfCompartmentTypes:</h3>
      <table class="w3-table w3-striped w3-border w3-hoverable w3-card-4" style="width: auto;max-width:90%;">
      <tr class="w3-blue-grey"><th>id</th><th>name</th><th>metaid</th></tr>
      <xsl:apply-templates select="*[local-name()='compartmentType']" mode="table"/>
      </table>
    </xsl:template>
    
    <xsl:template match="*[local-name()='compartmentType']" mode="table">
        <tr>
          <td class="w3-tooltip"><xsl:apply-templates select="@id" mode="table"/></td>
          <td><xsl:value-of select="@name"/></td>
          <td><xsl:value-of select="@metaid"/></td>
        </tr>
    </xsl:template>
    
    <!-- listOfSpeciesTypes -->
    <xsl:template match="*[local-name()='listOfSpeciesTypes']" mode="table">
      <h3>listOfSpeciesTypes:</h3>
      <table class="w3-table w3-striped w3-border w3-hoverable w3-card-4" style="width: auto;max-width:90%;">
      <tr class="w3-blue-grey"><th>id</th><th>name</th><th>metaid</th></tr>
      <xsl:apply-templates select="*[local-name()='speciesType']" mode="table"/>
      </table>
    </xsl:template>
    
    <xsl:template match="*[local-name()='speciesType']" mode="table">
        <tr>
          <td class="w3-tooltip"><xsl:apply-templates select="@id" mode="table"/></td>
          <td><xsl:value-of select="@name"/></td>
          <td><xsl:value-of select="@metaid"/></td>
        </tr>
    </xsl:template>
    
    <!-- listOfCompartments -->
    <xsl:template match="*[local-name()='listOfCompartments']" mode="table">
      <h3>listOfCompartments:</h3>
      <table class="w3-table w3-striped w3-border w3-hoverable w3-card-4" style="width: auto;max-width:90%;">
      <tr class="w3-blue-grey"><th>id</th><th>name</th><th>metaid</th><th>units</th><th>size</th></tr>
      <xsl:apply-templates select="*[local-name()='compartment']" mode="table"/>
      </table>
    </xsl:template>
    
    <xsl:template match="*[local-name()='compartment']" mode="table">
        <tr>
          <td class="w3-tooltip"><xsl:apply-templates select="@id" mode="table"/></td>
          <td><xsl:value-of select="@name"/></td>
          <td><xsl:value-of select="@metaid"/></td>
          <td><xsl:apply-templates select="@units" mode="table"/></td>
          <td><xsl:if test="not(key('variableKey', @id))"><xsl:value-of select="@size"/></xsl:if>
          <xsl:apply-templates select="key('variableKey', @id)/mml:math"/></td>
        </tr>
    </xsl:template>
    
  <!-- listOfSpecies -->
  <xsl:template match="*[local-name()='listOfSpecies']" mode="table">
      <h3>listOfSpecies:</h3>
      <table class="w3-table w3-striped w3-border w3-hoverable w3-card-4"  style="width: auto; max-width:90%;">
      <tr class="w3-blue-grey"><th>id</th><th>name</th><th>metaid</th><th>substance<br/>Units</th><th>initial<br/>Concentration</th><th>initial<br/>Amount</th><th>boundary<br/>Condition</th><th>compartment</th></tr>
        <xsl:apply-templates select="*[local-name()='species']" mode="table"/>
      </table>
  </xsl:template>
  
    <xsl:template match="*[local-name()='species']" mode="table">
        <tr>
          <td class="w3-tooltip"><xsl:apply-templates select="@id" mode="table"/></td>
          <td><xsl:value-of select="@name"/></td>
          <td><xsl:value-of select="@metaid"/></td>
          <td><xsl:apply-templates select="@substanceUnits" mode="table"/></td>
          <td><xsl:value-of select="@initialConcentration"/></td>
          <td><xsl:value-of select="@initialAmount"/></td>
          <td><xsl:value-of select="@boundaryCondition"/></td>
          <td><xsl:apply-templates select="key('idKey',@compartment)/@id" mode="idOrName"/></td>
        </tr>
    </xsl:template>
    
  <!-- listOfParameters -->
  <xsl:template match="*[local-name()='listOfParameters']" mode="table">
      <h3>listOfParameters:</h3>
      <table class="w3-table w3-striped w3-border w3-hoverable w3-card-4" style="width: auto; max-width:90%;">
      <tr class="w3-blue-grey"><th>id</th><th>name</th><th>metaid</th><th>units</th><th>value</th></tr>
        <xsl:apply-templates select="*[local-name()='parameter']" mode="table"/>
      </table>
  </xsl:template>
  
  <xsl:template match="*[local-name()='parameter']" mode="table">
        <tr>
          <td class="w3-tooltip"><xsl:apply-templates select="@id" mode="table"/></td>
          <td><xsl:value-of select="@name"/></td>
          <td><xsl:value-of select="@metaid"/></td>
          <td><xsl:value-of select="@units"/></td>
          <td>
          <xsl:if test="not(key('variableKey', @id))"><xsl:value-of select="@value"/></xsl:if>
          <xsl:apply-templates select="key('variableKey', @id)/mml:math"/>
          </td>
        </tr>
  </xsl:template>
    
  <!-- listOfInitialAssignments annotation -->
  <xsl:template match="*[local-name()='listOfInitialAssignments']" mode="table">
      <h3>listOfInitialAssignments:</h3>
      <table class="w3-table w3-striped w3-border w3-hoverable w3-card-4"  style="width: auto; max-width:90%;">
      <tr class="w3-blue-grey"><th>symbol</th><th>metaid</th><th>math:</th></tr>
        <xsl:apply-templates select="*[local-name()='initialAssignment']" mode="table"/>
      </table>
  </xsl:template>
  
  <xsl:template match="*[local-name()='initialAssignment']" mode="table">
        <tr>
          <td class="w3-tooltip"><xsl:apply-templates select="@symbol" mode="table"/></td>
          <td><xsl:value-of select="@metaid"/></td>
          <td><xsl:apply-templates select="mml:math"/></td>
        </tr>
  </xsl:template>
    
  <!-- listOfConstraints annotation -->
  <xsl:template match="*[local-name()='listOfConstraints']" mode="table">
      <h3>listOfConstraints:</h3>
      <table class="w3-table w3-striped w3-border w3-hoverable w3-card-4"  style="width: auto; max-width:90%;">
      <tr class="w3-blue-grey"><th>metaid</th><th>message</th><th>math:</th></tr>
        <xsl:apply-templates select="*[local-name()='constraint']" mode="table"/>
      </table>
  </xsl:template>
  
  <xsl:template match="*[local-name()='constraint']" mode="table">
        <tr>
          <td><xsl:value-of select="@metaid"/></td>
          <td><xsl:apply-templates select="*[local-name()='message']"  mode="table"/></td>
          <td><xsl:apply-templates select="mml:math"/></td>
        </tr>
  </xsl:template>
  
  <!-- listOfRules annotation -->
  <xsl:template match="*[local-name()='listOfRules']" mode="table">
      <h3>listOfRules:</h3>
      <table class="w3-table w3-striped w3-border w3-hoverable w3-card-4"  style="width: auto; max-width:90%;">
      <tr class="w3-blue-grey"><th>variable</th><th>metaid</th><th>math:</th></tr>
        <xsl:apply-templates select="*[local-name()='assignmentRule']" mode="table"/>
      </table>
  </xsl:template>
  
  <xsl:template match="*[local-name()='assignmentRule']" mode="table">
        <tr>
          <td class="w3-tooltip"><xsl:apply-templates select="@variable" mode="table"/></td>
          <td><xsl:value-of select="@metaid"/></td>
          <td><xsl:apply-templates select="mml:math"/></td>
        </tr>
  </xsl:template>
  
  <!-- listOfReactions annotation -->
  <xsl:template match="*[local-name()='listOfReactions']" mode="table">
      <h3>listOfReactions:</h3>
      <table class="w3-table w3-striped w3-border w3-hoverable w3-card-4" style="width: auto; max-width:90%;">
      <tr class="w3-blue-grey"><th>id</th><th>name</th><th>metaid</th><th>reaction formula:</th><th>math:</th></tr>
        <xsl:apply-templates select="*[local-name()='reaction']" mode="table"/>
      </table>
  </xsl:template>
  
  <xsl:template match="*[local-name()='reaction']" mode="table">
        <tr>
          <td class="w3-tooltip"><xsl:apply-templates select="@id" mode="table"/></td>
          <td><xsl:value-of select="@name"/></td>
          <td><xsl:value-of select="@metaid"/></td>
          <td><xsl:apply-templates select="." mode="reactionFormula"/></td>
          <td><xsl:apply-templates select="*[local-name()='kineticLaw']/mml:math"/></td>
        </tr>
  </xsl:template>
  
  <!-- listOfEvents annotation -->
  <xsl:template match="*[local-name()='listOfEvents']" mode="table">
      <h3>listOfEvents:</h3>
      <table class="w3-table w3-striped w3-border w3-hoverable w3-card-4"  style="width: auto; max-width:90%;">
      <tr class="w3-blue-grey"><th>id</th><th>name</th><th>metaid</th><th>useValuesFrom<br/>TriggerTime</th><th>trigger</th><th>delay</th><th>listOfEvent<br/>Assignments</th></tr>
        <xsl:apply-templates select="*[local-name()='event']" mode="table"/>
      </table>
  </xsl:template>
  
  <xsl:template match="*[local-name()='event']" mode="table">
        <tr>
          <td class="w3-tooltip"><xsl:apply-templates select="@id" mode="table"/></td>
          <td><xsl:value-of select="@name"/></td>
          <td><xsl:value-of select="@metaid"/></td>
          <td><xsl:value-of select="@useValuesFromTriggerTime"/></td>
          <td><xsl:apply-templates select="*[local-name()='trigger']" mode="table"/></td>
          <td><xsl:apply-templates select="*[local-name()='delay']" mode="table"/></td>
          <td><xsl:apply-templates select="*[local-name()='listOfEventAssignments']" mode="table"/></td>
          <td><xsl:apply-templates select="mml:math"/></td>
        </tr>
  </xsl:template>
  
  <xsl:template match="*[local-name()='trigger']" mode="table">
    <xsl:apply-templates select="mml:math"/>
  </xsl:template>
  
  <xsl:template match="*[local-name()='delay']" mode="table">
    <xsl:apply-templates select="mml:math"/>
  </xsl:template>
  
  <xsl:template match="@units" mode="table">
    <!--<i><xsl:apply-templates select="key('idKey',.)/@name" mode="table"/></i>-->
    <i><xsl:value-of select="."/></i>
  </xsl:template>
  
  <xsl:template match="@substanceUnits" mode="table">
    <!--<i><xsl:apply-templates select="key('idKey',.)/@name" mode="table"/>/<xsl:apply-templates select="key('idKey', key('idKey',../@compartment)/@units)/@name" mode="table"/></i>-->
    <i><xsl:value-of select="."/>/<xsl:value-of select="key('idKey',../@compartment)/@units"/></i>
  </xsl:template>
  
  <xsl:template match="*[local-name()='unitDefinition']/@name" mode="table">
    <xsl:value-of select="."/>
  </xsl:template>
  
  <!-- Notes type: just copy -->
  <xsl:template match="
    *[local-name()='notes'] |
    *[local-name()='message']
    " mode="table">
    <xsl:copy-of select="node()"/>
  </xsl:template>
  
  <!-- SId object: internal ref -->
  <xsl:template match="@variable|@species|@substanceUnits|@units|@compartment|@speciesType|@compartmentType|@outside">
      <xsl:value-of select="."/>
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
    <xsl:template match="*[local-name()='listOfUnits']" mode="unitFormula">
      <xsl:element name="math" namespace="http://www.w3.org/1998/Math/MathML">
        <xsl:element name="apply" namespace="http://www.w3.org/1998/Math/MathML">
          <xsl:element name="times" namespace="http://www.w3.org/1998/Math/MathML"/>
          <xsl:apply-templates select="*[local-name()='unit']" mode="unitFormula"/>
        </xsl:element>
      </xsl:element>
    </xsl:template>
    
    <xsl:template match="*[local-name()='unit']" mode="unitFormula">
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
    
    <!-- =TO DO= analysis of offset for l2v1
    <xsl:template match="l2v1:*[local-name()='unit']" mode="unitFormula">
     <xsl:element name="apply" namespace="http://www.w3.org/1998/Math/MathML">
      <xsl:element name="plus" namespace="http://www.w3.org/1998/Math/MathML"/>
      <xsl:element name="apply" namespace="http://www.w3.org/1998/Math/MathML">
        <xsl:element name="power" namespace="http://www.w3.org/1998/Math/MathML"/>
        <xsl:element name="apply" namespace="http://www.w3.org/1998/Math/MathML">
          <xsl:element name="times" namespace="http://www.w3.org/1998/Math/MathML"/>
          <xsl:apply-templates select="." mode="unitFormulaScale"/>
          <xsl:element name="ci" namespace="http://www.w3.org/1998/Math/MathML"><xsl:value-of select="@kind"/></xsl:element>
        </xsl:element>
        <xsl:element name="cn" namespace="http://www.w3.org/1998/Math/MathML"><xsl:value-of select="@exponent"/></xsl:element>
      </xsl:element>
      <xsl:element name="cn" namespace="http://www.w3.org/1998/Math/MathML"><xsl:value-of select="@offset"/></xsl:element>
     </xsl:element>
    </xsl:template>
    -->
    
    <xsl:template match="*[local-name()='unit' and @exponent='1']" mode="unitFormula">
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
    
    <xsl:template match="*[local-name()='unit' and @scale!='0']" mode="unitFormulaScale">
      <xsl:element name="cn" namespace="http://www.w3.org/1998/Math/MathML">
        <xsl:value-of select="@multiplier"/>e<xsl:value-of select="@scale"/>
      </xsl:element>
    </xsl:template>
    
    <xsl:template match="*[local-name()='unit' and not(@scale!='0') and not(@multiplier!='1') ]" mode="unitFormulaScale" />
<!-- END OF unitFormula/unitFormulaScale mode -->
    
<!-- BEGIN OF idOrName/idOrNamePlus mode -->
  <xsl:template match="@id|@variable" mode="idOrName">
      <xsl:if test="$useNames='true'"><xsl:value-of select="./../@name"/></xsl:if>  <!-- for simbio only-->
      <xsl:if test="not($useNames='true')"><xsl:value-of select="."/></xsl:if>
    </xsl:template>
    
    <xsl:template match="@id|@variable" mode="idOrNamePlus">
      <xsl:if test="$useNames='true'"><xsl:value-of select="./../@name"/></xsl:if>  <!-- for simbio only-->
      <xsl:if test="not($useNames='true')"><xsl:value-of select="."/></xsl:if>
       <div style="
         position:absolute; left:50%; bottom:90%; border-radius:6px; padding:8px; width:300px;
         " class="w3-text w3-pale-blue">
           <xsl:apply-templates select="../*[local-name()='notes']" />
         </div>
    </xsl:template>
<!-- END OF idOrName/idOrNamePlus mode -->
  
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
      <xsl:apply-templates select="key('idKey',@species)/@id" mode="idOrName"/>
      <xsl:if test="position()!=last()">+</xsl:if>
    </xsl:for-each>
  </xsl:template>
  
  <!-- listOfModifiers-->
  <xsl:template match="
    *[local-name()='listOfModifiers'] 
    " mode="reactionFormula">
    <xsl:if test="count(*[local-name()='modifierSpeciesReference'])>0"> ~ </xsl:if>
    <xsl:for-each select="*[local-name()='modifierSpeciesReference']">
      <xsl:apply-templates select="key('idKey',@species)/@id" mode="idOrName"/>
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
      <xsl:if test="$useNames='true'"><xsl:value-of select="key('idKey',normalize-space(text()))/@name"/></xsl:if>  <!-- for simbio only-->
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
    <xsl:element name="eq" namespace="http://www.w3.org/1998/Math/MathML"/>
    <xsl:element name="apply" namespace="http://www.w3.org/1998/Math/MathML">
      <xsl:element name="ci" namespace="http://www.w3.org/1998/Math/MathML">f</xsl:element>
      <xsl:apply-templates select="mml:bvar/mml:*"/>
    </xsl:element>
    <xsl:apply-templates select="*[local-name()!='bvar']"/>
    
   </xsl:element>
  </xsl:template>
<!-- END OF mml: part -->
</xsl:stylesheet>
