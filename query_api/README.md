# kooaba Web Services
Query API Version 1.1 (2009-05-09)

## Introduction

This document specifies the communication API (Application Programming Interface) for the kooaba object recognition service. This service allows to recognize rigid objects in digital images. The query image is sent via this API to our recognition server, where it is analyzed and compared against a pre-defined database of reference images. The content associated with the best match (this can be a keyword or just a hyperlink to a web site) is sent back if the recognition was successful. The content of this document covers the technical specifications concerning the communication via HTTP (Hypertext Transfer Protocol) to the kooaba recognition server. Many parts of the kooaba web services - like the authentication mechanism - are inspired by the [Amazon Web Services](http://docs.amazonwebservices.com/AmazonS3/latest/). For additional questions, please contact us.

## Authentication

The kooaba REST API uses a custom HTTP scheme. A request is authenticated as follows. First, selected elements of the request are concatenated to form a string. Then a KWS Secret Key (see definition below) is used to calculate a hash code of that string. This process is called "signing the request", and we call the output of hash code computation the "signature" because it simulates the security properties of a real signature. Finally, the signature is added as a parameter of the request, using the syntax described in this section.

### Definitions

#### KWS Access Key
Individual hexadecimal access key for each user provided by kooaba upon registration. Example: _df8d23140eb443505c0661c5b58294ef472baf64_


#### KWS Secret Key
Hexadecimal secret key to construct the signature together with the KWS Access key and some other selected elements of the request. Example: _054a431c8cd9c3cf819f3bc7aba592cc84c09ff7_

#### HTTP-Verb
The HTTP method used for the action. Example: _GET, POST_, etc.

#### Content-MD5
The hexadecimal MD5 hash (lowercase!) of the whole request body (from first boundary to last one, including the boundary itself). Use an empty string for request types without request body (GET, DELETE).

#### Content-Type
If using POST or PUT, the content-type of the request body (like _multipart/form-data_), for other types use an empty string.

#### Date
Current date, defined by [RFC 2616](http://www.ietf.org/rfc/rfc2616.txt), section 3.3.1. Example: _Sun, 06 Nov 1994 08:49:37 GMT_

### Constructing the Authentication Header

The kooaba REST API uses the standard HTTP Authorization header to pass authentication information. Under the kooaba authentication scheme, the Authorization header has the following form.

    Authorization: KWS {KWSAccessKey}:{Signature}

Developers are issued an KWS Access Key and KWS Secret Key. For request authentication, the KWSAccessKey element identifies the secret key that was used to compute the signature, and (indirectly) the developer making the request.

The Signature element is the SHA1 hash value of the KWS Secret Key combined with selected elements from the request, and so the Signature part of the Authorization header will vary from request to request. If the request signature calculated by the system matches the Signature included with the request, then the requester will have demonstrated possession to the KWS Secret Key. The request will then be processed under the identity, and with the authority, of the developer to whom the key was issued.

Following is pseudo-grammar that illustrates the construction of the Authorization request header (\n means the Unicode code point U+000A).

    Authorization = "KWS" + " " + KWSAccessKey + ":" + Signature;

    Signature = Base64(SHA1-Raw-Digest( StringToSign ) ) );

    StringToSign = KWSSecretKey + "\n\n" +

      HTTP-Verb + "\n" +

      Content-MD5 + "\n" +

      Content-Type + "\n" +

      Date + "\n" +

      Request-Path;

### Time Stamp Requirement

A valid time-stamp (using the HTTP Date header) is mandatory for authenticated requests. Furthermore, the client time-stamp included with an authenticated request must be within 15 minutes of the kooaba system time when the request is received. If not, the request will fail with the "Request Time Too Skewed" error status code.

## Components

#### Items
An item represents a rigid object consisting of one ore more reference images and metadata.

#### Groups
A group is a container for items in the image recognition system. Each API user is usually member of at least one group.

#### Queries
A query basically consists of an image and a list of groups to search the image in.

## Action: List Groups

__Verb__          : GET

__URL__           : http://search.kooaba.com/groups.xml

__Authorization__ : _See above_

Lists all the groups associated to the API user. Image queries can then be performed in one or more groups simultaneously.

### Sample Response

HTTP status code 200 (OK)


    <?xml version="1.0" encoding="UTF-8"?>
    <groups type="array">
      <group>
        <id type="integer">32</id>
        <title>Sample Group 1</title>
      </group>
      <group>
        <id type="integer">34</id>
        <title>Sample Group 2</title>
      </group>
    </groups>


## Action: Create Query

__Verb__ : POST

__URL__  : http://search.kooaba.com/queries.xml

Creating a new query is done by sending a multipart POST request to the URL defined above.  

### Request Headers

__Content-Type__ : This must be set to `multipart/form-data`

__Date__         : Current date, defined by RFC 2616

__Authorization__  : _See above_

### Request Body

The multipart MIME data as defined in [RFC 2388](http://www.ietf.org/rfc/rfc2388.txt). The _Create Query_ action needs at least two parts.

#### Image part (required)

##### Headers:
__Content-Type__              : _image/jpeg_ or _image/png_

__Content-Disposition__       :  _form-data; name="query[file]"_

__Content-Transfer-Encoding__ : _binary_

##### Content:
_[Binary Data]_

#### Group part

##### Headers:
__Content-Disposition__ : _form-data; name="query[group_ids][]"_

Content (type=integer), example: _32_

To search in multiple groups at once, please add as many group parts as needed.

### Sample Request

Note that the HTTP library you use will add addition headers (like _Accept_ and _Host_).


    Content-Type: multipart/form-data; boundary=49182cdfb857c
    Host: search.kooaba.com
    Date: Mon, 10 Nov 2008 12:45:19 GMT
    Authorization: KWS df8d23140eb443505c0661c5b58294ef472baf64:jHX6oLeqTXpynyqcvVC2MSHarhU=
    Content-Length: 85402

    --49182cdfb857c 
    Content-Disposition: form-data; name="query[group_ids][]" 

    32 
    --49182cdfb857c 
    Content-Disposition: form-data; name="query[file]"; filename="lena.jpg" 
    Content-Transfer-Encoding: binary 
    Content-Type: image/jpeg 

    [BINARY DATA]
    --49182cdfb857c-- 

## Responses

### Response with recognized image (Reveal)

HTTP status code 201 (Created)

    <?xml version="1.0" encoding="UTF-8"?>
    <query>
      <uuid>3o0nbgpai227erfe803r10osnd</uuid>
      <group-id type="integer">2</group-id>
      <item>
        <title>Wired</title>
      </item>
      <response>
        <type>RevealResponse</type>
        <content type="image/jpeg" url="http://0.0.0.0:3000/q/3o0nbgpai227erfe803r10osnd.jpg"/>
        <description nil="true"/>
      </response>
    </query>

### Response with recognized image (Text)

HTTP status code 201 (Created)

    <?xml version="1.0" encoding="UTF-8"?>
    <query>
      <uuid>4lkvlolbp727epnjg02kbm7occ</uuid>
      <group-id type="integer"></group-id>
      <item>
        <title>Lena</title>
      </item>
      <response nil="true"/>
    </query>

### Response without recognition

HTTP status code 201 (Created)

    <?xml version="1.0" encoding="UTF-8"?>
    <query>
      <uuid>4uqhf7lai327erfe803r10osnd</uuid>
      <group-id type="integer">2</group-id>
      <item nil="true"/>
      <response nil="true"/>
    </query>

### Error message when reached maximum number of requests within a certain time period

HTTP status code 403 (Forbidden)

    <?xml version="1.0" encoding="UTF-8"?>
    <errors>
      <error>You have reached maximum number of requests in a 24-hr period.</error>
    </errors>

### Error message when using group id without permission

HTTP status code 422 (Unprocessable Entity)

    <?xml version="1.0" encoding="UTF-8"?>
    <errors>
      <error>Group - Permission denied for Group with ID=1</error>
    </errors>

### Error message when using inexistent group id

HTTP status code 422 (Unprocessable Entity)

    <?xml version="1.0" encoding="UTF-8"?>
    <errors>
      <error>Group - Couldn't find Group with ID=1456</error>
    </errors>
