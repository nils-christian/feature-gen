package de.rhocas.featuregen.featureide.model.configuration;

import static org.hamcrest.collection.IsCollectionWithSize.hasSize;
import static org.hamcrest.collection.IsIterableContainingInOrder.contains;
import static org.hamcrest.core.Is.is;
import static org.hamcrest.core.IsInstanceOf.instanceOf;
import static org.junit.Assert.assertThat;

import java.util.List;
import java.util.stream.Collectors;

import javax.xml.XMLConstants;
import javax.xml.bind.JAXBContext;
import javax.xml.bind.JAXBException;
import javax.xml.bind.Unmarshaller;
import javax.xml.validation.Schema;
import javax.xml.validation.SchemaFactory;

import org.junit.Test;
import org.xml.sax.SAXException;

/**
 * A simple unit test that makes sure that both the configuration model is parsable with the XSD classes.
 *
 * @author Nils Christian Ehmke
 */
public final class ConfigurationModelTest {
  
	@Test
	public void configurationModelFileShouldBeParsable() throws JAXBException, SAXException {
		final Unmarshaller unmarshaller = createUnmarshaller( );

		final Object object = unmarshaller.unmarshal( getClass( ).getResource( "/configuration.xml" ) );
		assertThat( object, is( instanceOf( Configuration.class ) ) );

		final Configuration configuration = ( Configuration ) object;
		assertThat(configuration.feature, hasSize(8));
		
		List<String> featureNames = configuration.feature.stream().map(Feature::getName).collect(Collectors.toList());
		assertThat(featureNames, contains("Root", "F1", "F2", "F3", "F3.1", "F4", "F4.1", "F4.2"));
	} 
	 
	private Unmarshaller createUnmarshaller() throws JAXBException, SAXException {
		final JAXBContext jaxbContext = JAXBContext.newInstance( ObjectFactory.class );
		final Unmarshaller unmarshaller = jaxbContext.createUnmarshaller( );

		final SchemaFactory schemaFactory = SchemaFactory.newInstance( XMLConstants.W3C_XML_SCHEMA_NS_URI );
		final Schema schema = schemaFactory.newSchema( getClass( ).getResource( "/configuration.xsd" ) );
		unmarshaller.setSchema( schema );

		return unmarshaller;
	}
	
}
