--
-- PostgreSQL database dump
--

-- Dumped from database version 9.6.16
-- Dumped by pg_dump version 9.6.16

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: schoolclub_New; Type: DATABASE; Schema: -; Owner: postgres
--

CREATE DATABASE "schoolclub_New" WITH TEMPLATE = template0 ENCODING = 'UTF8' LC_COLLATE = 'English_United Kingdom.1252' LC_CTYPE = 'English_United Kingdom.1252';


ALTER DATABASE "schoolclub_New" OWNER TO postgres;

\connect "schoolclub_New"

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- Name: available_clubs(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.available_clubs(activityid integer) RETURNS TABLE(availableclubs integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
   RETURN QUERY
   SELECT activity.space - count(student_subscription.student_id) AS availableclubs
   FROM student_subscription
     JOIN event ON student_subscription.event_id = event.event_id
     JOIN activity ON activity.activity_id = event.activity_id
  WHERE student_subscription.approved = true AND activity.activity_id = activityId
  GROUP BY event.activity_id, event.day, activity.activity_id;
                   
END
$$;


ALTER FUNCTION public.available_clubs(activityid integer) OWNER TO postgres;

--
-- Name: getincomingareamovements(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getincomingareamovements(integer) RETURNS TABLE(activityid bigint)
    LANGUAGE plpgsql
    AS $_$
DECLARE
BEGIN
    return query SELECT activity.space - count(student_subscription.student_id) AS availableclubs
   FROM student_subscription
     JOIN event ON student_subscription.event_id = event.event_id
     JOIN activity ON activity.activity_id = event.activity_id
  WHERE student_subscription.approved = true AND activity.activity_id = $1
  GROUP BY event.activity_id, event.day, activity.activity_id;
END;
$_$;


ALTER FUNCTION public.getincomingareamovements(integer) OWNER TO postgres;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: activity; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.activity (
    activity_id integer NOT NULL,
    name character varying(255),
    type character varying(50),
    space integer,
    price numeric(5,2),
    is_active boolean DEFAULT true,
    school_id character varying(255) NOT NULL,
    combined_with_another_club boolean DEFAULT false,
    combined_tier_id integer DEFAULT 0
);


ALTER TABLE public.activity OWNER TO postgres;

--
-- Name: activity_activity_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.activity_activity_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.activity_activity_id_seq OWNER TO postgres;

--
-- Name: activity_activity_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.activity_activity_id_seq OWNED BY public.activity.activity_id;


--
-- Name: event; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.event (
    event_id integer NOT NULL,
    activity_id integer,
    tier_id integer,
    day character varying(10),
    term_id integer,
    note character varying(255),
    space integer,
    price numeric(5,2),
    is_active boolean DEFAULT true,
    school_id character varying(255) NOT NULL,
    year_id integer,
    deduct_days integer DEFAULT 0
);


ALTER TABLE public.event OWNER TO postgres;

--
-- Name: event_event_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.event_event_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.event_event_id_seq OWNER TO postgres;

--
-- Name: event_event_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.event_event_id_seq OWNED BY public.event.event_id;


--
-- Name: fee; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.fee (
    fee_id integer NOT NULL,
    activity_id integer NOT NULL,
    tier_id integer NOT NULL,
    price numeric(5,2),
    school_id character varying(255) NOT NULL
);


ALTER TABLE public.fee OWNER TO postgres;

--
-- Name: fee_fee_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.fee_fee_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.fee_fee_id_seq OWNER TO postgres;

--
-- Name: fee_fee_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.fee_fee_id_seq OWNED BY public.fee.fee_id;


--
-- Name: staff; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.staff (
    staff_id character varying(255) NOT NULL,
    first_name character varying(50),
    middle_name character varying(50),
    last_name character varying(50),
    po_box character varying(35),
    address_line_one character varying(95),
    address_line_two character varying(95),
    city character varying(35),
    state character varying(35),
    postal_code character varying(9),
    country character varying(70),
    email text,
    phone character varying(15),
    type character varying(20),
    year integer,
    school_id character varying(255)
);


ALTER TABLE public.staff OWNER TO postgres;

--
-- Name: staff_subscription; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.staff_subscription (
    subscribe_id integer NOT NULL,
    staff_id character varying(255) NOT NULL,
    event_id integer NOT NULL,
    leader boolean,
    school_id character varying(255) NOT NULL
);


ALTER TABLE public.staff_subscription OWNER TO postgres;

--
-- Name: term; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.term (
    term_id integer NOT NULL,
    term_name character varying(255),
    start_date date NOT NULL,
    end_date date NOT NULL,
    monday_count integer,
    tuesday_count integer,
    wednesday_count integer,
    thursday_count integer,
    friday_count integer,
    year_id integer,
    school_id character varying(255) NOT NULL,
    is_deleted boolean DEFAULT true,
    holiday character varying(255)
);


ALTER TABLE public.term OWNER TO postgres;

--
-- Name: tier; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tier (
    tier_id integer NOT NULL,
    name character varying(255),
    start_time character varying(255),
    end_time character varying(255),
    price numeric(5,2),
    note character varying(255),
    main boolean DEFAULT false,
    associate_tier_id integer,
    day character varying(15),
    school_id character varying(255) NOT NULL,
    term_id integer NOT NULL,
    is_active boolean DEFAULT true,
    year_id integer
);


ALTER TABLE public.tier OWNER TO postgres;

--
-- Name: get_all_events; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.get_all_events AS
 SELECT row_number() OVER (PARTITION BY true::boolean) AS row_number,
    tier.tier_id AS tierid,
    tier.name AS tiername,
    tier.start_time AS tierstarttime,
    tier.end_time AS tierendtime,
    tier.price AS tierprice,
    tier.note AS tiernote,
    term.term_id AS termid,
    term.term_name AS termname,
    activity.activity_id AS activityid,
    activity.name AS activtyname,
    activity.type AS activitytype,
    activity.space AS activityspace,
    event.price AS activityprice,
    activity.is_active AS isactive,
    event.event_id AS eventid,
    event.day AS eventday,
    event.note AS eventnote,
    event.space AS eventspaces,
    event.deduct_days AS deductdays,
    staff_subscription.subscribe_id AS subscribeid,
    staff.staff_id AS staffid,
    concat_ws(' '::text, NULLIF(btrim((staff.first_name)::text), ''::text), NULLIF(btrim((staff.middle_name)::text), ''::text), NULLIF(btrim((staff.last_name)::text), ''::text)) AS staffname,
    event.school_id AS schoolid,
    term.monday_count,
    term.tuesday_count,
    term.wednesday_count,
    term.thursday_count,
    term.friday_count,
    term.holiday,
    term.start_date,
    term.end_date
   FROM (((((public.event
     JOIN public.tier ON ((tier.tier_id = event.tier_id)))
     JOIN public.activity ON ((activity.activity_id = event.activity_id)))
     JOIN public.term ON ((event.term_id = term.term_id)))
     LEFT JOIN public.staff_subscription ON ((staff_subscription.event_id = event.event_id)))
     LEFT JOIN public.staff ON (((staff.staff_id)::text = (staff_subscription.staff_id)::text)))
  WHERE (event.is_active = true);


ALTER TABLE public.get_all_events OWNER TO postgres;

--
-- Name: get_all_invocies; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.get_all_invocies AS
SELECT
    NULL::bigint AS row_number,
    NULL::character varying(255) AS parentid,
    NULL::text AS parentname,
    NULL::character varying(255) AS parentemail,
    NULL::character varying(10) AS parentrelation,
    NULL::character varying(20) AS parentphoneno,
    NULL::integer AS studentid,
    NULL::text AS studentname,
    NULL::character varying(255) AS studentyear,
    NULL::integer AS invoiceid,
    NULL::integer AS invoiceno,
    NULL::date AS invoicedate,
    NULL::numeric(1000,2) AS invoiceamount,
    NULL::numeric AS totalbalance,
    NULL::character varying(255) AS invoicedescription,
    NULL::character varying(255) AS schoolid;


ALTER TABLE public.get_all_invocies OWNER TO postgres;

--
-- Name: invoice_receipt; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.invoice_receipt (
    transaction_id integer NOT NULL,
    invoice_id integer DEFAULT 0 NOT NULL,
    receipt_id integer DEFAULT 0 NOT NULL
);


ALTER TABLE public.invoice_receipt OWNER TO postgres;

--
-- Name: receipt; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.receipt (
    receipt_id integer NOT NULL,
    reference character varying(13) NOT NULL,
    receipt_date date,
    parent_id character varying(255),
    student_id integer,
    amount numeric(1000,2),
    description character varying(255),
    receipt_type character varying(20),
    school_id character varying(255) NOT NULL
);


ALTER TABLE public.receipt OWNER TO postgres;

--
-- Name: get_all_receipt_transaction; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.get_all_receipt_transaction AS
 SELECT row_number() OVER (PARTITION BY true::boolean) AS row_number,
    invoice_receipt.invoice_id AS invoiceid,
    receipt.receipt_id AS receiptid,
    receipt.reference,
    receipt.receipt_date AS receiptdate,
    receipt.amount,
    receipt.description,
    receipt.receipt_type AS receipttype,
    receipt.school_id AS schoolid
   FROM (public.receipt
     JOIN public.invoice_receipt ON ((receipt.receipt_id = invoice_receipt.receipt_id)));


ALTER TABLE public.get_all_receipt_transaction OWNER TO postgres;

--
-- Name: invoice; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.invoice (
    invoice_id integer NOT NULL,
    invoice_no integer NOT NULL,
    parent_id character varying(255),
    student_id integer,
    invoice_date date,
    amount numeric(1000,2),
    description character varying(255),
    school_id character varying(255) NOT NULL
);


ALTER TABLE public.invoice OWNER TO postgres;

--
-- Name: parent; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.parent (
    parent_id character varying(255) NOT NULL,
    first_name character varying(50),
    middle_name character varying(50),
    last_name character varying(50),
    po_box character varying(35),
    address_line_one character varying(95),
    address_line_two character varying(95),
    city character varying(35),
    state character varying(35),
    postal_code character varying(9),
    country character varying(70),
    mobile character varying(20),
    phone_no character varying(20),
    email character varying(255),
    relationship character varying(10),
    school_id character varying(255) NOT NULL
);


ALTER TABLE public.parent OWNER TO postgres;

--
-- Name: student; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.student (
    student_id integer NOT NULL,
    title character varying(50),
    first_name character varying(50),
    middle_name character varying(50),
    last_name character varying(50),
    po_box character varying(35),
    address_line_one character varying(95),
    address_line_two character varying(95),
    city character varying(35),
    state character varying(35),
    postal_code character varying(9),
    country character varying(70),
    date_of_birth date NOT NULL,
    year character varying(255),
    is_active boolean DEFAULT true,
    medical_consideration text,
    dietary_consideration text,
    school_id character varying(255)
);


ALTER TABLE public.student OWNER TO postgres;

--
-- Name: student_parents; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.student_parents (
    student_id integer NOT NULL,
    parent_id character varying(255) NOT NULL,
    relation_id integer NOT NULL
);


ALTER TABLE public.student_parents OWNER TO postgres;

--
-- Name: get_all_receipts; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.get_all_receipts AS
 SELECT row_number() OVER (PARTITION BY true::boolean) AS row_number,
    parent.parent_id AS parentid,
    concat_ws(' '::text, NULLIF(btrim((parent.first_name)::text), ''::text), NULLIF(btrim((parent.middle_name)::text), ''::text), NULLIF(btrim((parent.last_name)::text), ''::text)) AS parentname,
    parent.email AS parentemail,
    parent.relationship AS parentrelation,
    parent.phone_no AS parentphoneno,
    student.student_id AS studentid,
    concat_ws(' '::text, NULLIF(btrim((student.first_name)::text), ''::text), NULLIF(btrim((student.middle_name)::text), ''::text), NULLIF(btrim((student.last_name)::text), ''::text)) AS studentname,
    student.year AS studentyear,
    receipt.receipt_id AS receiptid,
    receipt.reference,
    receipt.receipt_date AS receiptdate,
    receipt.receipt_type AS receipttype,
    receipt.amount AS receiptamount,
    invoice.invoice_id AS invoiceid,
    invoice.invoice_date AS invoicedate,
    invoice.amount AS invoicetotal,
    receipt.school_id AS schoolid
   FROM (((((public.receipt
     JOIN public.student_parents ON ((student_parents.student_id = receipt.student_id)))
     JOIN public.student ON ((student_parents.student_id = student.student_id)))
     JOIN public.parent ON (((student_parents.parent_id)::text = (parent.parent_id)::text)))
     JOIN public.invoice_receipt ON ((invoice_receipt.receipt_id = receipt.receipt_id)))
     JOIN public.invoice ON ((invoice.invoice_id = invoice_receipt.invoice_id)));


ALTER TABLE public.get_all_receipts OWNER TO postgres;

--
-- Name: school; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.school (
    school_id character varying(255) NOT NULL,
    school_name character varying(255) NOT NULL,
    postal_code character varying(20),
    school_address character varying(255),
    school_email character varying(255),
    phone_no_one bigint,
    phone_no_two bigint,
    is_active boolean DEFAULT true,
    is_deleted boolean DEFAULT false,
    school_logo bytea DEFAULT '\x6956424f5277304b47676f414141414e5355684555674141414a59414141435743415941414141384158486941414157396b6c45515652346e4f3264655a4263523333486e7934663863486c32795a674c6763545972415473446b534536664359584441594b41437751564637735255555345784a4345546f46496b46654a776d4343447646674951563774484f2f586532686a537975747848715252374b6b396352723761356d5a72742f7636666474535566736956726436667a78335a506e6b6137633732653654666139366e366c62537a73362f37392b7676363965765438654a69596d4a69596d4a69596d4a69596d4a69596d4a69596d4a69596d4a69596d4a69596d4a69596d4a4d595072756d747975647a356e5050626965672b49686f525168776b6f6d6b69656f61496e694f694678447852534936515554504539477a52485355694151525059614944784c524e3451514e306b7031795553696457322f5970704d39505430356369346e635263596149356f686f6759696b515375706137354152486b6878422b4e6a593164594e7676474d4e777a6c394f5248635230544844416d72594548452f352f7a39325778326e65323478445242735668384753496d694f696b6254465645646d34454f4c57776348427462626a46564d44525077734555335a466b3244746b424551346a344474767869776e677575346149727250392f32354349676b7244306a684c6a44646b78584e4f76587231386e6848444a664f506274705551385954762b782b7a48654d56685a52794e524735455242415777775250326b37356d633869506a4a4d3743477173656d447830363943726238542f6a344a7866535a33584b44647551676733666f733042434c2b6e4259374861305862455473526337355232795853386553792b584f703855684664734647556b54516d797a5855596468784469566f70727158727332506a342b4957327936736a6f425830786d664946754a485978554742776658457446544553696f6a6a524533477937444350482b506a3468625134473842364158577943534565746c32576b57467161756f4b5770792b597231677a6843627346326d317547637634346932456a3366583965546577376a6f6776454e4668496a70415241635163596f5733316150302b4c73695368323245354c4b56666d5a4d4f7071616e58527141414a4245393566752b4a34533473316773587373355037645258325a6d5a73376e6e503847352f774c694c68666964477158346834644d574a61325a6d356a4b4c41542b42694275454544634f4467366530796f66392b2f666635345134754f494f4552453835623870566235467a6c55513732746253726639303853555a4a7a2f6a6f6250696353696457633837636a346835712f36502f6632333433465a556c304c6248684f49654a7949666c394b7563713237786f7035646c43694b39524739746d694c6a567474387468647258547a5572684c6a4f74722b3145454c6332533642435348757365317653364432394b67663435792f7a62617639564973466c2f57726c714c6947516e78615975314e68664b344d326a3468667375316e4936674a692b3175314d2f6e382f6d57766243304654564c6f5a5842656d7838665078733233343243684564624c4f6f74506d3266546543372f7450747968414a534c366f6d332f6d6f467a2f694e4c6f704a454a42487858747378434155692f71784677546d5a7a2b6376732b31664d33444f503242545650716d4c42514b5639754f52564f6f36635374364c4f5a366451655a642f334c323552544a7170745937616a6b645449434a76515442324f6f34546d543670526b676b45717370417376384b2b78753233467043455438524174456462397476384b4169474d5245464b6c7a632f4f7a6e6247686958714e64703070312b2f62622f433450762b647949676f75567378485a38366f4c4d6434512b5a74756e4d4167686269467a37617044616c6a4d3647596e68554c686a62626a5642586c74456c526466536b4e534b36694d7a56336964797564785a6a6d4f2b787834525a323348716970714c77565444682b545571367837564f7a714a764d31504b314568476473684961456138784c4b3558326f7056565651675464326443357a7a4b323337464159687843384e467671532b7a6367346c385a464e66686473656f4c684478683661634c42614c486232566a7844695877794b36722b72705556456f3462534b676b6858744775474e554e475a71386834683762667353686b4f48446c316e734261704f6136587a5762586b626e423741507469464864714a3330544469326f42756f6e636a6b354f524c7946427a414246503950583131545734546b54764d68582f534730366f6c61756d48447330375a39615259703552704550476f6f4471564770314762366f4246784c39755659776177754372723744745378675138574644635a425455314f66617a523949766f56512b6c48597747473270303474454f46517546793237343043784639785a536f694b67335244372b793051655a6d646e375a634647576734496d4c5274682f4e516b532f5a6c42555434624a6978704f4339334c6a346a664e525766706c43623834634f7142446944565964615a4a734e6d767138534f4a364b534a467863687845594465566b77455a2b6d6f63555448384936385952564a35706e46526e7357546531356c474a505853746c63766c7a6a65526e365967412f4f4c4550483372446b51416b543868616e614368456262717a58794e74413244785a33572f65524a55627063576b39574c7168555556594a2f702f42574c7854635a794e756f36587a5678665430394b57744443706a374d4d41634151416a6e5231645a57584c41474144774248367530387242665864633843674b4d367a6142356e74656a767a63354f666c6d553649696f75644d2b6843454445797461565865716f4b493377326238576f6a36674477636361595a49784a4150686e2f546c6a37446e476d41794b7a5153753635366c30317643746a754f3433444f7a7a556f716e6d542b612b4569454933347133736236724f2b77755438626c713136385156766e4f726961737672362b6931335862586762496b30716c626f6b6c557064776867377167576453715575536166544c31552b50362f7a507a55314a59502f463049736465504971616d7055373672724451354f666c36783345634b6557713374376579326f646e696d6c584a564b7053375a7548486a656658344d6a6b352b61746868635535622f394943495566644e35643766706157414351593479566b736e6b6178786e615745427741384159434567784c45776a306f414f4d49596b35376e2f61332b444247484a79596d4a474e4d3774793555774b41374f6e706b635044777849414a474e4d35765035737144362b2f736c414a534e4d535a333764716c66662b38387555577874696379764f4c795754794e7362595850424755766c4a4d735957416a556f757135376353302f31433437595a346f7738334773436e55695674684231732f5769324e5149323143514157414941357a756e43596f7a395a794467497747426e576a57763070684564452f4546464a4332746759454275336270564d73624b346d4b4d79643237643565467852695432375a746b2f7632375a505a6246594c586f364f6a7659367a754c387455432b6a7746416b544657556a382f722f5043474e756d506c7341674238777867727135366f3176754d344469495751777172765576454468382b6646375961725a57476c70596e756474416f444e414444764f4d36716f4c41536963527158546965352f326d2b744e5641444450474a5064336431766173612f6f4c4349364871645a793273306446526d632f6e4a574e4d62742b2b58584c4f4a514449776348427372443076396f65656551524c614948484d6478504d2f376e426156547063786c67304b7136757236787a3163326e54706b305842764933712f4c337157702b4343472b474c4b63616f72584b4a7a7a6a375a54574a376e5861722b6632745157497978693753774b763732455656442f4c415a2f375377656e74374578546f624e544379755679736c67736c6839765167674a41504b68687834714332706f61476935463445744b6f31686c63662f30656d6d302b6b6267734a4b70564a76304c555659367758414c59447748624732465071627765712b66484545303963464c4b63536d30394f4230523777755a595634726a614377484d64785644434c414641576c7575366c79306a72496455344a7361304e584332724e6e7a796e747946724365764442427955527959474267624b51686f614764473331432f585a6779714e55655666557165625371562b505369735443627a376d584571522b746a3954794a617977686f65486d33345a6168676947676d5a34533231307167556c756435663636437561434674576e54706774316b4f2b343434377977677647324954362f41764e2b4b654674586676336c507958612b77644a35475230643144666158414e416446425a6a374676715a784649393536677341493354744f50704c4250467337352b35704e753245514d657757504839634b34314b59665831395a306476467431347830417074566e7631412f2f34372b7a6f594e472b706535657536376872503837374d474c7362414635676a4d6b644f336249505876326c415853714c43554d507564786261684441704c6457766f3975463678746a6e6c326d387a366e766643755133565541384a4e304f7633614f7370714f6b785a4353482b724e3459686f6149516d5632656e7236306c70705641724c635279484d625a374357466448536951344750694f343334564b32445644664b367858577777382f48507a373479702f52345043556e6e66474d68376954486d56676f726d557a65754a522f6a44465a6a37434961487649537542726a63517846416232764c716f5668724a5a504a36414c6a583837773739576341634455413341734139363566763336642f6e7a392b765872414f446e6e756339415141374d356e4d757876314b5a4649724f3376373938344d6a49694b2b335252782b565243547a2b62776347526d5245784d546b6e4d7552305a4735494544427951697970475245626c6e7a3536796a2f7632375a746a6a44334b474476676564366e504d2b37465144755a597a6446557a332f767676767a69547958776d6d5578656e6b366e33364a75696d6372386e614f35336b2f426f4448414f42787868674177422f55343563516f6a746b6a64572b50544f49364c6b776d543179354d684c3270625a4f6c4754355079514e347932556a3337665871656c2b727036586d6a36377072656e703658675941683152745a4777416d49692b46644b586c4b6d38314a505a55467471487a3538754b35686958614369474249564249522f3636654e48562f57345756366e6e453155765976717932627557747a706c704f724e52327a4d554554396e536c52456c4b3033335751796554316248466b34444141494150643064585739314b5276516f67375176705464656a4e4b455230496b786d6f37527a62364651754e7967714a364c32767779745a6438307a344a49646f33586b68457a34664a374d7a4d6a4c3170727748792b6677355244536e68313143696d7075636e4979636d314852507871534c3971396a6b616734696544566c6a476133756d30464b75556f76744e557a45494a355245525a4c425a504d63353574547637706d7270655a35336865643556795153695756584775767661444d786d5245527530494b7977326268376f686f724172666d74324e37516152505230666e544475564a5977576b7641464475646c6a43617662314244704472316e713936377272716e737238706b4d6838773447656f2b65394369505a7433593249496b786d693858697457334c374e4c352f325177503774323751724f6c536f4c4b35764e796d77324b3374376579566a62446c683162586a594331684f59367a79764f38684f643543514234317143777369457267532b487a554d6a6d633246795377692f744e793130346b457174643131316a596c5264587976596f4a36596d4c676b4b4a36674c5a66662f76372b4a595746694d647270616570464a6272757374754b7363597733714570644e7a7175776b48665a51546948456e637464327a69492b474249595a33327070484a5a4b3756643270774f43536454742b6776724a4b6a35756c55716e79416c6664573830594b383868423442764c7a454d4d6a49774d484165715a586259324e6a707a33714768545767703454376e6e656a35635955746f5a334c6b6c38506c7636526b616a4c47465a444a356657557361676d7271367672484430314b43445966313371757946724b316b6f464e3561747a4443516b546643436d7349355858544b5653747a50475367437731664f382b7742676c2b347731413165414f685668624e522f35306162354d4173435077575a34784e674d41535144344956507a6c375a753356724f773847444232562f6633395a4e4a567472467243436a62575655636e4d635a6341506752592b775a6c61654d2f6b3541574338436747442f507956355070764e6c6f656e31486558465659696b56697442386b5a597751412f5144776f727257615a75306852525771544a764c6156514b4c776a374a315165553358645639652b666a544261516648366c55366a6f5630424f4237387779786d527662322b35466b736d6b316346722b4e3533685856784e4f6f734951512f786938666d56502b514d505050414b5664446c70657142326d5737343577364e646e7a764e73712f463557574a6c4d35724f564d584264392b58364a67772b596732734c79773537547977515571356a6b49753439362f662f3870777a70396658316e41384159592b776b5932786557556b56304166313939536458686f634844786e7734594e462b6a434356374c38377a334163424d3444727a706f534669507371342b4635336d314b344b656c70777336494b796239642b704157554a414e384f58712b617348524e726e72724277426777504f384c557774746b676d6b2b5764596f6a6f5030492b5759355870743953315045646f525a54564a347679426837556265564147437635336c442b6e47527957512b70723848414872717a4963387a37744442586d582f6e306d6b336c376f4243663775767265327a62746d336c6c544a68684c56333739375441733059757a3651336c4e736361616f6e6930716454737255447464452f4346716338335646797a6d724247646532306c4b58543656667237314c4962694572323352542b4c4f64797874384a5a504a79774e3365486c5a45325073574b577747474d33712b396d47574f44624c45782f36374137332b714261705745383056436f577134716b6c7243316274756a32306439587869485146707a556e323361744f6d7135595256635a4d38716137376a65413147574e636666636a5336536e7031332f70467235474e725371476f614c5947493869457a5857352f624e36382b5649642b46517164596e6a4f453533642f66726c796f4d78316b734a41435931394f554b39362b394276615042454a49696f767a77714b4a396a4e45507a64556c30504f336273304d4b61645633332f455169735661334277476772314a59414a4265546c694d4d542b52534b7831586666715143313279707558576a416847574d48586463394e35686554302b506e67632f483679646b736e6b717743676644524d735668385a386a796b55523067394e75697358695a384a6d5841687869373665727033554933464369575a684b574870746f6d7952344f2f387a7a76477632377672362b5539373667754b426973576b536a684c506a4950486a7a34665662526661466e714b625436566348506a764d467474612b72462b6d724141594654357071393332687479643366336d344a7071622f37555342572b774b2f4f364866436c6c676272794a33584371396257316a4c4778735176435a6877527933746a71566d6757324678597735557766325a366a4b344d5a6732414e796f506b39366e76664f79727a7433372f2f62375a7332534a376533766c746d3362354e54556c42776147704a4451304e6c59656d666c374e41506e63376a754f34726e757835336e66302b6c6d4d706e50362f51796d63796247574f434d66593041477a647347484442624334656a6d6c46336b77786c4c717379735a5978356a374367413748646464386e4e316c547a3450733650514434692b44764d356e4d6539556a38326b416d50553862366937752f76316a754d3475567a754c414f5051547562676a694f6b57324d6a452b6849614c516578594537466a74464b4f48696533524558477a545166326858574163333558375a5471513070355674684a694146626f41674d6c6a634445595864734b586d624932573476762b2b773363475363635135317752445268734c623662524e35616a636d64706b68736a7a4c56335755686e61436331353167354236514d53666d684956496e375452487873594f67674166743737695069754146486e713264307649513065326d524f58376672544f6b326d4138664878433033456f4b307a47705a44434847727a5670725a6d626d4d6f4d31315445727239694749444e4e6756496b46727559504b6577306254566133576f2b666342572b6a77307a46754d48527a3762487453786c4533476e4971585344365a6f364762364569423971565878616a5a712f4832726c6c445968784874732b314e6d656e72364a6c4d462f4f535454395a3173716f51597232684e43556933746671474c55534963535044635869704731665473503366564f6e4e42797274545a504350456567364c7132484e38484d64784a69596d586b6b4765746d56505744626e394e514b32364e4f4f6a37506979586a6a7073306f696f694769756b7738306c314b754e74676858497255495a6842694f693471554c6e6e4c2b2f3876714467344e725462556c6947684243484856556e3530436b51556467564f734f5a7571483362566e7a662f356a42327152554c425a664537772b4559566148565152794e755738364d54494b4b7647347931624f7663396d5977365377524c6567394d496e6f2b3661754b345459574d75504b4d4d354e3959687243785a4f31584c494f496e444474395841687843356c726f4e59384754374b634d35764e68674c535854362b6f5049676f697a6873566c78487a66622b6e354e61304745643971576c53496d4c447456393049496136794c614b6c724a4e37316a6e6e62794e44497877425562583335416b54454a46725730684234357a66626a736d7a534b452b4a4e57784151523237664b32525271444e465548307459612b7145696968415247455061316a4f666d6e627436596867394e5a517479565537626a304179717a7937736676724c32594b4a67383274676f68624c517072586b725a76724e67444d4535667a4d5a626b3846545168786e5730666a55446d707259305a4a3357574664444e42746147524d687848726266687244314d7a4752737a45644f6432516b522f534b31766b785a732b326b6349767077473458562f7158685456496f464b346d74574b3778545958786633316a5943496d39736b7241556963694d3757753834546a36666677735a574b5a5670355749364c514e3373346f455048684e745a63456848335257555751794b52574332452b434169486d746a44457149574e65354f783050455532325531784b594d385430622b506a342f58504b54624a464c4b56554b4936346a6f30586237724b79704d787337466d7266593241706b5a305151695135357a6562626e636b456f6e5668773464757454332f53386834754f6b396a7931354f652f6d665374493144374e3455396e7336492b62352f6b6f6847685241624566455478574c78326e772b66396c796e596935584f36736644372f557337356c554b496d78447871346734524552464d6a784948454a55503231336d55594731572f4462526443486262672b2f3463746244543072436f566c354e745254716b574739514d34414b33484f5631616271685a43694730524b4a694f7468587a3974636f516f68376242644f68396f636e656e3956474878666639745a50464e71744d4d4551753558433453782f5246487337357562534939594b4c73703152413872744242487674563134456257464d326271697933554947306b2b727369594355692b6d584854394b4c456b52304e36336774686369487533494f657164774f7a73374156454e474b376b4332494b6d45373969754359724634625654584c68713235426b376879724b71433138446c4e457875634d57516b52303548665332456c38506a6a6a372b436941355168347a6c4c574d6e69656942547434443959786c634842774c6566384c6c7245746c4471725a33324343462b313362735975716b554368633776762b6479694362354b494b49515164306f703765394f484e4d3859324e6a4636676442782b7a4b4b624e516f69624972485664557872474238667635427a2f6d6c45484562456f37513469467569634338424a66566f4f363765574839534c425a76694e744d4b3578454972463665486a3458434a364c7848397152446936304b492b7845783766762b513053305777677854455439524f516934766549364374436944734c68634a62705a52726e5859657a42305445784d5445784d5445784d5445784d5445784d5445784d5445784d5445784d5445784d5445374e532b442b2b6361664351503734524141414141424a52553545726b4a6767673d3d'::bytea
);


ALTER TABLE public.school OWNER TO postgres;

--
-- Name: year; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.year (
    year_id integer NOT NULL,
    year_name character varying(255),
    school_id character varying(255),
    description character varying(255),
    from_date date NOT NULL,
    to_date date NOT NULL,
    is_active boolean DEFAULT true,
    year_road character varying(255)
);


ALTER TABLE public.year OWNER TO postgres;

--
-- Name: get_all_schools; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.get_all_schools AS
 SELECT school.school_id AS schoolid,
    school.school_name AS schoolname,
    school.postal_code AS postalcode,
    school.school_address AS schooladdress,
    school.school_email AS schoolemail,
    school.phone_no_one AS phonenoone,
    school.phone_no_two AS phonenotwo,
    year.year_id AS yearid,
    year.year_name AS yearname,
    year.description,
    year.from_date AS formdate,
    year.to_date AS todate
   FROM (public.school
     JOIN public.year ON (((year.school_id)::text = (school.school_id)::text)))
  WHERE ((school.is_active = true) AND (year.is_active = true));


ALTER TABLE public.get_all_schools OWNER TO postgres;

--
-- Name: student_subscription; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.student_subscription (
    subscribe_id integer NOT NULL,
    event_id integer NOT NULL,
    student_id integer NOT NULL,
    year integer NOT NULL,
    subscrib_on timestamp without time zone DEFAULT now(),
    term_id integer,
    approved boolean DEFAULT false,
    combine_tier_id integer,
    reference_id character varying(255),
    school_id character varying(255)
);


ALTER TABLE public.student_subscription OWNER TO postgres;

--
-- Name: subscribe_transaction; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.subscribe_transaction (
    payment_id integer NOT NULL,
    subscribe_id integer NOT NULL,
    parent_id character varying(255),
    student_id integer,
    combine_id integer NOT NULL,
    term_id integer NOT NULL,
    amount numeric(5,2),
    approved_date timestamp without time zone DEFAULT now(),
    invoice_id integer DEFAULT 0,
    day_count integer,
    school_id character varying(255)
);


ALTER TABLE public.subscribe_transaction OWNER TO postgres;

--
-- Name: get_all_subscribe_transaction; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.get_all_subscribe_transaction AS
 SELECT row_number() OVER (PARTITION BY true::boolean) AS row_number,
    subscribe_transaction.invoice_id AS invoiceid,
    subscribe_transaction.payment_id AS approvedid,
    subscribe_transaction.approved_date AS approveddate,
    parent.parent_id AS parentid,
    concat_ws(' '::text, NULLIF(btrim((parent.first_name)::text), ''::text), NULLIF(btrim((parent.middle_name)::text), ''::text), NULLIF(btrim((parent.last_name)::text), ''::text)) AS parentname,
    student.student_id AS studentid,
    concat_ws(' '::text, NULLIF(btrim((student.first_name)::text), ''::text), NULLIF(btrim((student.middle_name)::text), ''::text), NULLIF(btrim((student.last_name)::text), ''::text)) AS studentname,
    term.term_name AS termname,
    event.day AS eventdate,
    subscribe_transaction.day_count AS noofdays,
    tier.tier_id AS tierid,
    tier.name AS tiername,
    tier.start_time AS starttime,
    tier.end_time AS endtime,
    tier.price AS tierprice,
    ((subscribe_transaction.day_count)::numeric * event.price) AS totalamount,
    activity.name AS club,
    subscribe_transaction.school_id AS schoolid
   FROM ((((((((public.subscribe_transaction
     JOIN public.student_subscription ON ((subscribe_transaction.subscribe_id = student_subscription.subscribe_id)))
     JOIN public.student_parents ON ((student_parents.student_id = subscribe_transaction.student_id)))
     JOIN public.student ON ((student_parents.student_id = student.student_id)))
     JOIN public.parent ON (((student_parents.parent_id)::text = (parent.parent_id)::text)))
     JOIN public.term ON ((student_subscription.term_id = term.term_id)))
     JOIN public.event ON ((student_subscription.event_id = event.event_id)))
     JOIN public.activity ON ((activity.activity_id = event.activity_id)))
     JOIN public.tier ON ((tier.tier_id = student_subscription.combine_tier_id)))
  ORDER BY
        CASE
            WHEN ((event.day)::text = 'sunday'::text) THEN 1
            WHEN ((event.day)::text = 'monday'::text) THEN 2
            WHEN ((event.day)::text = 'tuesday'::text) THEN 3
            WHEN ((event.day)::text = 'wednesday'::text) THEN 4
            WHEN ((event.day)::text = 'thursday'::text) THEN 5
            WHEN ((event.day)::text = 'friday'::text) THEN 6
            WHEN ((event.day)::text = 'saturday'::text) THEN 7
            ELSE NULL::integer
        END, tier.start_time, tier.end_time;


ALTER TABLE public.get_all_subscribe_transaction OWNER TO postgres;

--
-- Name: get_all_subscribes; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.get_all_subscribes AS
 SELECT row_number() OVER (PARTITION BY true::boolean) AS row_number,
    event.event_id AS eventid,
    event.price AS eventprice,
    event.day AS eventday,
    tier.tier_id AS tierid,
    tier.name AS tiername,
    activity.activity_id AS activityid,
    activity.name AS activityname,
    student.student_id AS studentid,
    concat_ws(' '::text, NULLIF(btrim((student.first_name)::text), ''::text), NULLIF(btrim((student.middle_name)::text), ''::text), NULLIF(btrim((student.last_name)::text), ''::text)) AS studentname,
    student_subscription.subscribe_id AS subscribeid,
    term.term_id AS termid,
    term.start_date AS startdate,
    term.end_date AS enddate,
    student_subscription.school_id AS schoolid,
    student_subscription.approved
   FROM (((((public.student_subscription
     JOIN public.student ON ((student.student_id = student_subscription.student_id)))
     JOIN public.event ON ((event.event_id = student_subscription.event_id)))
     JOIN public.tier ON ((tier.tier_id = event.tier_id)))
     JOIN public.activity ON ((activity.activity_id = event.activity_id)))
     JOIN public.term ON ((term.term_id = student_subscription.term_id)))
  WHERE (('now'::text)::date <= term.end_date);


ALTER TABLE public.get_all_subscribes OWNER TO postgres;

--
-- Name: tier_combine_term; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tier_combine_term (
    combine_tier_id integer NOT NULL,
    tier_id integer,
    main boolean DEFAULT false,
    associate_id integer,
    term_id integer,
    is_active boolean DEFAULT true,
    note character varying(255)
);


ALTER TABLE public.tier_combine_term OWNER TO postgres;

--
-- Name: get_all_tiers; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.get_all_tiers AS
 SELECT row_number() OVER (PARTITION BY true::boolean) AS row_number,
    tier.tier_id AS tierid,
    tier.name AS tiername,
    tier.start_time AS tierstarttime,
    tier.end_time AS tierendtime,
    tier.price AS tierprice,
    tier_combine_term.main AS tiertype,
    term.term_id AS termid,
    term.term_name AS termname,
    term.start_date AS termstartdate,
    term.end_date AS termenddate,
    term.year_id AS termyearid,
    tier.year_id AS tieryearid,
    tier.school_id AS tierschoolid,
    tier_combine_term.associate_id AS associateid,
    tier_combine_term.combine_tier_id AS combinetierid
   FROM ((public.tier
     LEFT JOIN public.tier_combine_term ON ((tier_combine_term.tier_id = tier.tier_id)))
     LEFT JOIN public.term ON ((term.term_id = tier_combine_term.term_id)))
  WHERE ((tier.is_active = true) AND (tier_combine_term.is_active = true))
  ORDER BY tier.tier_id;


ALTER TABLE public.get_all_tiers OWNER TO postgres;

--
-- Name: get_approved_subscribe_data; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.get_approved_subscribe_data AS
 SELECT row_number() OVER (PARTITION BY true::boolean) AS row_number,
    subscribe_transaction.payment_id AS approveid,
    subscribe_transaction.approved_date AS approvedate,
    student.student_id AS studentid,
    concat_ws(' '::text, NULLIF(btrim((student.first_name)::text), ''::text), NULLIF(btrim((student.middle_name)::text), ''::text), NULLIF(btrim((student.last_name)::text), ''::text)) AS studentname,
    parent.parent_id AS parentid,
    concat_ws(' '::text, NULLIF(btrim((parent.first_name)::text), ''::text), NULLIF(btrim((parent.middle_name)::text), ''::text), NULLIF(btrim((parent.last_name)::text), ''::text)) AS parentname,
    student_subscription.year AS studentyear,
    term.term_id AS termid,
    term.term_name AS termname,
    tier.name AS tiername,
    activity.name AS clubname,
    event.day AS eventday,
    subscribe_transaction.day_count AS noofdays,
    ((subscribe_transaction.day_count)::numeric * event.price) AS amount,
    subscribe_transaction.school_id AS schoolid
   FROM ((((((((public.subscribe_transaction
     JOIN public.student_subscription ON ((subscribe_transaction.subscribe_id = student_subscription.subscribe_id)))
     JOIN public.student ON ((student.student_id = student_subscription.student_id)))
     JOIN public.student_parents ON ((student_parents.student_id = student_subscription.student_id)))
     JOIN public.parent ON (((parent.parent_id)::text = (student_parents.parent_id)::text)))
     JOIN public.event ON ((event.event_id = student_subscription.event_id)))
     JOIN public.tier ON ((tier.tier_id = student_subscription.combine_tier_id)))
     JOIN public.activity ON ((activity.activity_id = event.activity_id)))
     JOIN public.term ON ((term.term_id = student_subscription.term_id)))
  WHERE (subscribe_transaction.invoice_id = 0);


ALTER TABLE public.get_approved_subscribe_data OWNER TO postgres;

--
-- Name: get_avalibale_clubs; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.get_avalibale_clubs AS
SELECT
    NULL::bigint AS row_number,
    NULL::bigint AS studentcount,
    NULL::integer AS activity_id,
    NULL::integer AS term_id,
    NULL::character varying(10) AS day,
    NULL::integer AS space,
    NULL::bigint AS availablespace,
    NULL::text AS status;


ALTER TABLE public.get_avalibale_clubs OWNER TO postgres;

--
-- Name: hibernate_sequence; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.hibernate_sequence
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.hibernate_sequence OWNER TO postgres;

--
-- Name: invoice_invoice_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.invoice_invoice_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.invoice_invoice_id_seq OWNER TO postgres;

--
-- Name: invoice_invoice_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.invoice_invoice_id_seq OWNED BY public.invoice.invoice_id;


--
-- Name: invoice_receipt_transaction_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.invoice_receipt_transaction_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.invoice_receipt_transaction_id_seq OWNER TO postgres;

--
-- Name: invoice_receipt_transaction_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.invoice_receipt_transaction_id_seq OWNED BY public.invoice_receipt.transaction_id;


--
-- Name: parent_bookings; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.parent_bookings AS
 SELECT row_number() OVER (PARTITION BY true::boolean) AS row_number,
    a.subscribe_id,
    p.parent_id,
    concat_ws(' '::text, NULLIF(btrim((p.first_name)::text), ''::text), NULLIF(btrim((p.middle_name)::text), ''::text), NULLIF(btrim((p.last_name)::text), ''::text)) AS parentname,
    s.student_id,
    concat_ws(' '::text, NULLIF(btrim((s.first_name)::text), ''::text), NULLIF(btrim((s.middle_name)::text), ''::text), NULLIF(btrim((s.last_name)::text), ''::text)) AS studentname,
    a.year,
    s.medical_consideration AS medicalconsideration,
    s.dietary_consideration AS dietaryconsideration,
    ac.activity_id AS activityid,
    ac.name AS activityname,
    ac.space AS activityspace,
    t.tier_id AS tierid,
    t.name AS tier,
    e.day AS days,
    COALESCE(st.day_count, 0) AS noofdays,
    e.deduct_days AS deductdays,
        CASE
            WHEN ((a.approved)::text = 'true'::text) THEN 'Approved'::text
            ELSE 'Pending'::text
        END AS status,
    t.price AS tierprice,
    COALESCE(((st.day_count)::numeric * e.price), 0.00) AS price,
    te.term_id AS termid,
    te.term_name AS termname,
    te.start_date AS termstartdate,
    te.end_date AS termenddate,
    a.subscrib_on AS bookingdate,
    a.school_id AS schoolid,
    te.holiday
   FROM ((((((((public.student_subscription a
     JOIN public.student s ON ((a.student_id = s.student_id)))
     JOIN public.student_parents sp ON ((s.student_id = sp.student_id)))
     JOIN public.parent p ON (((sp.parent_id)::text = (p.parent_id)::text)))
     JOIN public.event e ON ((a.event_id = e.event_id)))
     JOIN public.tier t ON ((t.tier_id = a.combine_tier_id)))
     JOIN public.activity ac ON ((ac.activity_id = e.activity_id)))
     JOIN public.term te ON ((a.term_id = te.term_id)))
     LEFT JOIN public.subscribe_transaction st ON ((st.subscribe_id = a.subscribe_id)));


ALTER TABLE public.parent_bookings OWNER TO postgres;

--
-- Name: payments_outstanding_view; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.payments_outstanding_view AS
SELECT
    NULL::bigint AS row_number,
    NULL::character varying(255) AS parent_id,
    NULL::text AS parentname,
    NULL::integer AS student_id,
    NULL::text AS childname,
    NULL::numeric AS amountoutstanding,
    NULL::integer AS term_id,
    NULL::character varying(255) AS termname,
    NULL::double precision AS year;


ALTER TABLE public.payments_outstanding_view OWNER TO postgres;

--
-- Name: receipt_receipt_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.receipt_receipt_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.receipt_receipt_id_seq OWNER TO postgres;

--
-- Name: receipt_receipt_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.receipt_receipt_id_seq OWNED BY public.receipt.receipt_id;


--
-- Name: repoert_amts_outstanding; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.repoert_amts_outstanding AS
 SELECT row_number() OVER (PARTITION BY true::boolean) AS row_number,
    p.parent_id,
    concat_ws(' '::text, NULLIF(btrim((p.first_name)::text), ''::text), NULLIF(btrim((p.middle_name)::text), ''::text), NULLIF(btrim((p.last_name)::text), ''::text)) AS parentname,
    s.student_id,
    concat_ws(' '::text, NULLIF(btrim((s.first_name)::text), ''::text), NULLIF(btrim((s.middle_name)::text), ''::text), NULLIF(btrim((s.last_name)::text), ''::text)) AS childname,
    t.tier_id,
    t.name AS tier,
    ac.activity_id,
    ac.name AS club,
    e.day AS days,
        CASE
            WHEN ((e.day)::text = 'Monday'::text) THEN te.monday_count
            WHEN ((e.day)::text = 'Tuesday'::text) THEN te.tuesday_count
            WHEN ((e.day)::text = 'Wednesday'::text) THEN te.wednesday_count
            WHEN ((e.day)::text = 'Thursday'::text) THEN te.thursday_count
            WHEN ((e.day)::text = 'Friday'::text) THEN te.friday_count
            WHEN (e.day IS NULL) THEN ((((te.monday_count + te.tuesday_count) + te.wednesday_count) + te.thursday_count) + te.friday_count)
            ELSE NULL::integer
        END AS lengthofbooking,
        CASE
            WHEN ((e.day)::text = 'Monday'::text) THEN ((te.monday_count)::numeric * t.price)
            WHEN ((e.day)::text = 'Tuesday'::text) THEN ((te.tuesday_count)::numeric * t.price)
            WHEN ((e.day)::text = 'Wednesday'::text) THEN ((te.wednesday_count)::numeric * t.price)
            WHEN ((e.day)::text = 'Thursday'::text) THEN ((te.thursday_count)::numeric * t.price)
            WHEN ((e.day)::text = 'Friday'::text) THEN ((te.friday_count)::numeric * t.price)
            WHEN (e.day IS NULL) THEN ((((((te.monday_count + te.tuesday_count) + te.wednesday_count) + te.thursday_count) + te.friday_count))::numeric * t.price)
            ELSE (NULL::integer)::numeric
        END AS fullamountdue,
        CASE
            WHEN ((e.day)::text = 'Monday'::text) THEN ((te.monday_count)::numeric * subtrans.amount)
            WHEN ((e.day)::text = 'Tuesday'::text) THEN ((te.tuesday_count)::numeric * subtrans.amount)
            WHEN ((e.day)::text = 'Wednesday'::text) THEN ((te.wednesday_count)::numeric * subtrans.amount)
            WHEN ((e.day)::text = 'Thursday'::text) THEN ((te.thursday_count)::numeric * subtrans.amount)
            WHEN ((e.day)::text = 'Friday'::text) THEN ((te.friday_count)::numeric * subtrans.amount)
            WHEN (e.day IS NULL) THEN ((((((te.monday_count + te.tuesday_count) + te.wednesday_count) + te.thursday_count) + te.friday_count))::numeric * subtrans.amount)
            ELSE (NULL::integer)::numeric
        END AS amountpaid,
    te.term_id,
    te.term_name AS termname,
        CASE
            WHEN ((e.day)::text = 'Monday'::text) THEN ((te.monday_count)::numeric * (t.price - subtrans.amount))
            WHEN ((e.day)::text = 'Tuesday'::text) THEN ((te.tuesday_count)::numeric * (t.price - subtrans.amount))
            WHEN ((e.day)::text = 'Wednesday'::text) THEN ((te.wednesday_count)::numeric * (t.price - subtrans.amount))
            WHEN ((e.day)::text = 'Thursday'::text) THEN ((te.thursday_count)::numeric * (t.price - subtrans.amount))
            WHEN ((e.day)::text = 'Friday'::text) THEN ((te.friday_count)::numeric * (t.price - subtrans.amount))
            WHEN (e.day IS NULL) THEN ((((((te.monday_count + te.tuesday_count) + te.wednesday_count) + te.thursday_count) + te.friday_count))::numeric * (t.price - subtrans.amount))
            ELSE (NULL::integer)::numeric
        END AS totalamountoutstanding,
    a.event_id,
    a.school_id AS schoolid
   FROM (((((((((((public.student_subscription a
     JOIN public.student s ON ((a.student_id = s.student_id)))
     JOIN public.student_parents sp ON ((s.student_id = sp.student_id)))
     JOIN public.parent p ON (((sp.parent_id)::text = (p.parent_id)::text)))
     JOIN public.event e ON ((a.event_id = e.event_id)))
     JOIN public.tier t ON ((t.tier_id = e.tier_id)))
     JOIN public.activity ac ON ((ac.activity_id = e.activity_id)))
     JOIN public.term te ON ((a.term_id = te.term_id)))
     JOIN public.receipt rec ON ((s.student_id = rec.student_id)))
     JOIN public.invoice inv ON ((s.student_id = inv.student_id)))
     JOIN public.invoice_receipt invrec ON (((inv.invoice_id = invrec.invoice_id) AND (rec.receipt_id = invrec.invoice_id))))
     JOIN public.subscribe_transaction subtrans ON (((subtrans.subscribe_id = invrec.invoice_id) AND (subtrans.student_id = a.student_id))))
  ORDER BY p.parent_id, s.student_id, te.term_id;


ALTER TABLE public.repoert_amts_outstanding OWNER TO postgres;

--
-- Name: repoert_amts_paid; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.repoert_amts_paid AS
 SELECT row_number() OVER (PARTITION BY true::boolean) AS row_number,
    p.parent_id,
    concat_ws(' '::text, NULLIF(btrim((p.first_name)::text), ''::text), NULLIF(btrim((p.middle_name)::text), ''::text), NULLIF(btrim((p.last_name)::text), ''::text)) AS parentname,
    s.student_id,
    concat_ws(' '::text, NULLIF(btrim((s.first_name)::text), ''::text), NULLIF(btrim((s.middle_name)::text), ''::text), NULLIF(btrim((s.last_name)::text), ''::text)) AS childname,
    t.name AS tier,
    ac.name AS club,
    e.day AS days,
        CASE
            WHEN ((e.day)::text = 'Monday'::text) THEN te.monday_count
            WHEN ((e.day)::text = 'Tuesday'::text) THEN te.tuesday_count
            WHEN ((e.day)::text = 'Wednesday'::text) THEN te.wednesday_count
            WHEN ((e.day)::text = 'Thursday'::text) THEN te.thursday_count
            WHEN ((e.day)::text = 'Friday'::text) THEN te.friday_count
            WHEN (e.day IS NULL) THEN ((((te.monday_count + te.tuesday_count) + te.wednesday_count) + te.thursday_count) + te.friday_count)
            ELSE NULL::integer
        END AS lengthofbooking,
        CASE
            WHEN ((e.day)::text = 'Monday'::text) THEN ((te.monday_count)::numeric * rec.amount)
            WHEN ((e.day)::text = 'Tuesday'::text) THEN ((te.tuesday_count)::numeric * rec.amount)
            WHEN ((e.day)::text = 'Wednesday'::text) THEN ((te.wednesday_count)::numeric * rec.amount)
            WHEN ((e.day)::text = 'Thursday'::text) THEN ((te.thursday_count)::numeric * rec.amount)
            WHEN ((e.day)::text = 'Friday'::text) THEN ((te.friday_count)::numeric * rec.amount)
            WHEN (e.day IS NULL) THEN ((((((te.monday_count + te.tuesday_count) + te.wednesday_count) + te.thursday_count) + te.friday_count))::numeric * rec.amount)
            ELSE (NULL::integer)::numeric
        END AS amountpaid,
    te.start_date AS startdate,
    te.end_date AS enddate,
    te.term_name AS termname,
    a.school_id AS schoolid
   FROM ((((((((public.student_subscription a
     JOIN public.student s ON ((a.student_id = s.student_id)))
     JOIN public.student_parents sp ON ((s.student_id = sp.student_id)))
     JOIN public.parent p ON (((sp.parent_id)::text = (p.parent_id)::text)))
     JOIN public.event e ON ((a.event_id = e.event_id)))
     JOIN public.tier t ON ((t.tier_id = e.tier_id)))
     JOIN public.activity ac ON ((ac.activity_id = e.activity_id)))
     JOIN public.term te ON ((a.term_id = te.term_id)))
     JOIN public.receipt rec ON ((s.student_id = rec.student_id)))
  ORDER BY (concat_ws(' '::text, NULLIF(btrim((s.first_name)::text), ''::text), NULLIF(btrim((s.middle_name)::text), ''::text), NULLIF(btrim((s.last_name)::text), ''::text)));


ALTER TABLE public.repoert_amts_paid OWNER TO postgres;

--
-- Name: repoert_club_register; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.repoert_club_register AS
 SELECT row_number() OVER (PARTITION BY true::boolean) AS row_number,
    p.parent_id,
    concat_ws(' '::text, NULLIF(btrim((p.first_name)::text), ''::text), NULLIF(btrim((p.middle_name)::text), ''::text), NULLIF(btrim((p.last_name)::text), ''::text)) AS parentname,
    s.student_id,
    concat_ws(' '::text, NULLIF(btrim((s.first_name)::text), ''::text), NULLIF(btrim((s.middle_name)::text), ''::text), NULLIF(btrim((s.last_name)::text), ''::text)) AS childname,
    s.year,
    ac.activity_id,
    ac.name AS club,
    e.day AS days,
    st.approved_date,
    te.term_name AS termname,
    a.school_id AS schoolid,
    concat(t.name, ' ', t.start_time, '-', t.end_time) AS tiername
   FROM ((((((((public.student_subscription a
     JOIN public.student s ON ((a.student_id = s.student_id)))
     JOIN public.student_parents sp ON ((s.student_id = sp.student_id)))
     JOIN public.parent p ON (((sp.parent_id)::text = (p.parent_id)::text)))
     JOIN public.event e ON ((a.event_id = e.event_id)))
     JOIN public.tier t ON ((t.tier_id = e.tier_id)))
     JOIN public.term te ON ((a.term_id = te.term_id)))
     JOIN public.activity ac ON ((ac.activity_id = e.activity_id)))
     JOIN public.subscribe_transaction st ON ((a.subscribe_id = st.subscribe_id)))
  ORDER BY te.term_id, e.day;


ALTER TABLE public.repoert_club_register OWNER TO postgres;

--
-- Name: repoert_existing_analysis; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.repoert_existing_analysis AS
 SELECT row_number() OVER (PARTITION BY true::boolean) AS row_number,
    p.parent_id,
    concat_ws(' '::text, NULLIF(btrim((p.first_name)::text), ''::text), NULLIF(btrim((p.middle_name)::text), ''::text), NULLIF(btrim((p.last_name)::text), ''::text)) AS parentname,
    s.student_id,
    concat_ws(' '::text, NULLIF(btrim((s.first_name)::text), ''::text), NULLIF(btrim((s.middle_name)::text), ''::text), NULLIF(btrim((s.last_name)::text), ''::text)) AS childname,
    t.name AS tier,
    ac.name AS club,
    initcap((e.day)::text) AS days,
    st.day_count AS lengthofbooking,
    te.term_name AS termname,
    (e.price * (st.day_count)::numeric) AS fullamountdue,
    a.school_id AS schoolid,
    s.year
   FROM (((((((((public.student_subscription a
     JOIN public.student s ON ((a.student_id = s.student_id)))
     JOIN public.student_parents sp ON ((s.student_id = sp.student_id)))
     JOIN public.parent p ON (((sp.parent_id)::text = (p.parent_id)::text)))
     JOIN public.event e ON ((a.event_id = e.event_id)))
     JOIN public.tier t ON ((t.tier_id = e.tier_id)))
     JOIN public.activity ac ON ((ac.activity_id = e.activity_id)))
     JOIN public.term te ON ((a.term_id = te.term_id)))
     JOIN public.term trmevent ON ((e.term_id = trmevent.term_id)))
     JOIN public.subscribe_transaction st ON ((a.subscribe_id = st.subscribe_id)))
  ORDER BY s.student_id;


ALTER TABLE public.repoert_existing_analysis OWNER TO postgres;

--
-- Name: repoert_for_parent; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.repoert_for_parent AS
 SELECT row_number() OVER (PARTITION BY true::boolean) AS row_number,
    p.parent_id,
    concat_ws(' '::text, NULLIF(btrim((p.first_name)::text), ''::text), NULLIF(btrim((p.middle_name)::text), ''::text), NULLIF(btrim((p.last_name)::text), ''::text)) AS parentname,
    s.student_id,
    concat_ws(' '::text, NULLIF(btrim((s.first_name)::text), ''::text), NULLIF(btrim((s.middle_name)::text), ''::text), NULLIF(btrim((s.last_name)::text), ''::text)) AS childname,
    ac.name AS club,
    t.name AS tier,
    e.day AS days,
    date_part('day'::text, ((te.end_date)::timestamp without time zone - (te.start_date)::timestamp without time zone)) AS noofdays,
    a.approved AS status,
    t.price,
    te.term_name AS termname,
    a.school_id AS schoolid
   FROM (((((((public.student_subscription a
     JOIN public.student s ON ((a.student_id = s.student_id)))
     JOIN public.student_parents sp ON ((s.student_id = sp.student_id)))
     JOIN public.parent p ON (((sp.parent_id)::text = (p.parent_id)::text)))
     JOIN public.event e ON ((a.event_id = e.event_id)))
     JOIN public.tier t ON ((t.tier_id = e.tier_id)))
     JOIN public.activity ac ON ((ac.activity_id = e.activity_id)))
     JOIN public.term te ON ((a.term_id = te.term_id)))
  ORDER BY te.term_name, (concat_ws(' '::text, NULLIF(btrim((s.first_name)::text), ''::text), NULLIF(btrim((s.middle_name)::text), ''::text), NULLIF(btrim((s.last_name)::text), ''::text)));


ALTER TABLE public.repoert_for_parent OWNER TO postgres;

--
-- Name: repoert_pupil_analysis; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.repoert_pupil_analysis AS
 SELECT row_number() OVER (PARTITION BY true::boolean) AS row_number,
    p.parent_id,
    concat_ws(' '::text, NULLIF(btrim((p.first_name)::text), ''::text), NULLIF(btrim((p.middle_name)::text), ''::text), NULLIF(btrim((p.last_name)::text), ''::text)) AS parentname,
    s.student_id,
    concat_ws(' '::text, NULLIF(btrim((s.first_name)::text), ''::text), NULLIF(btrim((s.middle_name)::text), ''::text), NULLIF(btrim((s.last_name)::text), ''::text)) AS childname,
    ac.name AS activity_name,
    t.tier_id,
    t.name AS tiername,
    t.start_time,
    t.end_time,
    (e.price * (st.day_count)::numeric) AS price,
    initcap((e.day)::text) AS days,
    te.term_name AS termname,
    a.school_id AS schoolid,
    s.year
   FROM ((((((((public.student_subscription a
     JOIN public.student s ON ((a.student_id = s.student_id)))
     JOIN public.student_parents sp ON ((s.student_id = sp.student_id)))
     JOIN public.parent p ON (((sp.parent_id)::text = (p.parent_id)::text)))
     JOIN public.event e ON ((a.event_id = e.event_id)))
     JOIN public.tier t ON ((t.tier_id = e.tier_id)))
     JOIN public.activity ac ON ((ac.activity_id = e.activity_id)))
     JOIN public.term te ON ((a.term_id = te.term_id)))
     JOIN public.subscribe_transaction st ON ((st.subscribe_id = a.subscribe_id)))
  ORDER BY te.term_id, t.tier_id;


ALTER TABLE public.repoert_pupil_analysis OWNER TO postgres;

--
-- Name: report_parent_invoice; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.report_parent_invoice AS
SELECT
    NULL::bigint AS row_number,
    NULL::character varying(255) AS school_id,
    NULL::character varying(255) AS parent_id,
    NULL::text AS parent_name,
    NULL::integer AS student_id,
    NULL::text AS student_name,
    NULL::numeric AS full_amount;


ALTER TABLE public.report_parent_invoice OWNER TO postgres;

--
-- Name: report_parent_receipt; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.report_parent_receipt AS
SELECT
    NULL::bigint AS row_number,
    NULL::character varying(255) AS school_id,
    NULL::character varying(255) AS parent_id,
    NULL::text AS parent_name,
    NULL::integer AS student_id,
    NULL::text AS student_name,
    NULL::numeric AS full_amount;


ALTER TABLE public.report_parent_receipt OWNER TO postgres;

--
-- Name: staff_subscription_subscribe_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.staff_subscription_subscribe_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.staff_subscription_subscribe_id_seq OWNER TO postgres;

--
-- Name: staff_subscription_subscribe_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.staff_subscription_subscribe_id_seq OWNED BY public.staff_subscription.subscribe_id;


--
-- Name: student_attendance; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.student_attendance (
    attendance_id integer NOT NULL,
    subscribe_id integer NOT NULL,
    student_id integer NOT NULL,
    attended boolean,
    attendance_date date,
    day character varying(10),
    school_id character varying(255) NOT NULL
);


ALTER TABLE public.student_attendance OWNER TO postgres;

--
-- Name: student_attendance_attendance_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.student_attendance_attendance_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.student_attendance_attendance_id_seq OWNER TO postgres;

--
-- Name: student_attendance_attendance_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.student_attendance_attendance_id_seq OWNED BY public.student_attendance.attendance_id;


--
-- Name: student_attendane; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.student_attendane AS
 SELECT row_number() OVER (PARTITION BY true::boolean) AS row_number,
    a.payment_id,
    a.subscribe_id,
    e.event_id,
    e.activity_id,
    ac.name AS activity_name,
    sp.parent_id,
    concat_ws(' '::text, NULLIF(btrim((p.first_name)::text), ''::text), NULLIF(btrim((p.middle_name)::text), ''::text), NULLIF(btrim((p.last_name)::text), ''::text)) AS parent_name,
    a.student_id,
    concat_ws(' '::text, NULLIF(btrim((s.first_name)::text), ''::text), NULLIF(btrim((s.middle_name)::text), ''::text), NULLIF(btrim((s.last_name)::text), ''::text)) AS student_name,
    e.day AS event_day,
    a.term_id,
    te.term_name,
    a.combine_id,
    a.school_id AS schoolid
   FROM (((((((public.subscribe_transaction a
     JOIN public.student s ON ((a.student_id = s.student_id)))
     JOIN public.student_subscription ss ON ((a.subscribe_id = ss.subscribe_id)))
     JOIN public.event e ON ((ss.event_id = e.event_id)))
     JOIN public.activity ac ON ((e.activity_id = ac.activity_id)))
     JOIN public.student_parents sp ON ((a.student_id = sp.student_id)))
     JOIN public.parent p ON (((sp.parent_id)::text = (p.parent_id)::text)))
     JOIN public.term te ON ((a.term_id = te.term_id)));


ALTER TABLE public.student_attendane OWNER TO postgres;

--
-- Name: student_list_with_parent; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.student_list_with_parent AS
 SELECT student_parents.student_id AS studentid,
    concat_ws(' '::text, NULLIF(btrim((student.first_name)::text), ''::text), NULLIF(btrim((student.middle_name)::text), ''::text), NULLIF(btrim((student.last_name)::text), ''::text)) AS studentname,
    concat_ws(' '::text, NULLIF(btrim((student.po_box)::text), ''::text), NULLIF(btrim((student.address_line_one)::text), ''::text), NULLIF(btrim((student.address_line_two)::text), ''::text), NULLIF(btrim((student.city)::text), ''::text), NULLIF(btrim((student.state)::text), ''::text), NULLIF(btrim((student.postal_code)::text), ''::text), NULLIF(btrim((student.country)::text), ''::text)) AS studentaddress,
    student.first_name AS studentfirstname,
    student.middle_name AS studentmiddlename,
    student.last_name AS studentlastname,
    student.po_box AS studentpobox,
    student.address_line_one AS studentaddresslineone,
    student.address_line_two AS studentaddresslinetwo,
    student.city AS studentcity,
    student.state AS studentstate,
    student.postal_code AS studentpostalcode,
    student.country AS studentcountry,
    student.year AS studentyear,
    student.date_of_birth AS dateofbirth,
    student.medical_consideration AS medicalconsideration,
    student.dietary_consideration AS dietaryconsideration,
    parent.parent_id AS parentid,
    concat_ws(' '::text, NULLIF(btrim((parent.first_name)::text), ''::text), NULLIF(btrim((parent.middle_name)::text), ''::text), NULLIF(btrim((parent.last_name)::text), ''::text)) AS parentname,
    concat_ws(' '::text, NULLIF(btrim((parent.po_box)::text), ''::text), NULLIF(btrim((parent.address_line_one)::text), ''::text), NULLIF(btrim((parent.address_line_two)::text), ''::text), NULLIF(btrim((parent.city)::text), ''::text), NULLIF(btrim((parent.state)::text), ''::text), NULLIF(btrim((parent.postal_code)::text), ''::text), NULLIF(btrim((parent.country)::text), ''::text)) AS parentaddress,
    student.school_id AS schoolid
   FROM ((public.student
     JOIN public.student_parents ON ((student_parents.student_id = student.student_id)))
     JOIN public.parent ON (((parent.parent_id)::text = (student_parents.parent_id)::text)))
  WHERE (student.is_active = true);


ALTER TABLE public.student_list_with_parent OWNER TO postgres;

--
-- Name: student_parents_relation_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.student_parents_relation_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.student_parents_relation_id_seq OWNER TO postgres;

--
-- Name: student_parents_relation_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.student_parents_relation_id_seq OWNED BY public.student_parents.relation_id;


--
-- Name: student_student_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.student_student_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.student_student_id_seq OWNER TO postgres;

--
-- Name: student_student_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.student_student_id_seq OWNED BY public.student.student_id;


--
-- Name: student_subscription_subscribe_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.student_subscription_subscribe_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.student_subscription_subscribe_id_seq OWNER TO postgres;

--
-- Name: student_subscription_subscribe_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.student_subscription_subscribe_id_seq OWNED BY public.student_subscription.subscribe_id;


--
-- Name: subscribe_transaction_payment_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.subscribe_transaction_payment_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.subscribe_transaction_payment_id_seq OWNER TO postgres;

--
-- Name: subscribe_transaction_payment_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.subscribe_transaction_payment_id_seq OWNED BY public.subscribe_transaction.payment_id;


--
-- Name: term_term_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.term_term_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.term_term_id_seq OWNER TO postgres;

--
-- Name: term_term_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.term_term_id_seq OWNED BY public.term.term_id;


--
-- Name: tier_combine_term_combine_tier_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.tier_combine_term_combine_tier_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.tier_combine_term_combine_tier_id_seq OWNER TO postgres;

--
-- Name: tier_combine_term_combine_tier_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tier_combine_term_combine_tier_id_seq OWNED BY public.tier_combine_term.combine_tier_id;


--
-- Name: tier_tier_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.tier_tier_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.tier_tier_id_seq OWNER TO postgres;

--
-- Name: tier_tier_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tier_tier_id_seq OWNED BY public.tier.tier_id;


--
-- Name: vw_term; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vw_term AS
 SELECT a.term_id,
    a.term_name,
    a.start_date,
    a.end_date,
    a.day_name,
    count(a.day_name) AS day_count
   FROM ( SELECT term.term_id,
            term.term_name,
            term.start_date,
            term.end_date,
            to_char(generate_series((term.start_date)::timestamp without time zone, (term.end_date)::timestamp without time zone, '1 day'::interval), 'Day'::text) AS day_name
           FROM public.term) a
  GROUP BY a.term_id, a.term_name, a.start_date, a.end_date, a.day_name;


ALTER TABLE public.vw_term OWNER TO postgres;

--
-- Name: year_year_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.year_year_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.year_year_id_seq OWNER TO postgres;

--
-- Name: year_year_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.year_year_id_seq OWNED BY public.year.year_id;


--
-- Name: activity activity_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.activity ALTER COLUMN activity_id SET DEFAULT nextval('public.activity_activity_id_seq'::regclass);


--
-- Name: event event_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.event ALTER COLUMN event_id SET DEFAULT nextval('public.event_event_id_seq'::regclass);


--
-- Name: fee fee_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.fee ALTER COLUMN fee_id SET DEFAULT nextval('public.fee_fee_id_seq'::regclass);


--
-- Name: invoice_receipt transaction_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.invoice_receipt ALTER COLUMN transaction_id SET DEFAULT nextval('public.invoice_receipt_transaction_id_seq'::regclass);


--
-- Name: staff_subscription subscribe_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.staff_subscription ALTER COLUMN subscribe_id SET DEFAULT nextval('public.staff_subscription_subscribe_id_seq'::regclass);


--
-- Name: student student_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.student ALTER COLUMN student_id SET DEFAULT nextval('public.student_student_id_seq'::regclass);


--
-- Name: student_attendance attendance_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.student_attendance ALTER COLUMN attendance_id SET DEFAULT nextval('public.student_attendance_attendance_id_seq'::regclass);


--
-- Name: student_parents relation_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.student_parents ALTER COLUMN relation_id SET DEFAULT nextval('public.student_parents_relation_id_seq'::regclass);


--
-- Name: student_subscription subscribe_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.student_subscription ALTER COLUMN subscribe_id SET DEFAULT nextval('public.student_subscription_subscribe_id_seq'::regclass);


--
-- Name: subscribe_transaction payment_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.subscribe_transaction ALTER COLUMN payment_id SET DEFAULT nextval('public.subscribe_transaction_payment_id_seq'::regclass);


--
-- Name: term term_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.term ALTER COLUMN term_id SET DEFAULT nextval('public.term_term_id_seq'::regclass);


--
-- Name: tier tier_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tier ALTER COLUMN tier_id SET DEFAULT nextval('public.tier_tier_id_seq'::regclass);


--
-- Name: tier_combine_term combine_tier_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tier_combine_term ALTER COLUMN combine_tier_id SET DEFAULT nextval('public.tier_combine_term_combine_tier_id_seq'::regclass);


--
-- Name: year year_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.year ALTER COLUMN year_id SET DEFAULT nextval('public.year_year_id_seq'::regclass);


--
-- Data for Name: activity; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.activity (activity_id, name, type, space, price, is_active, school_id, combined_with_another_club, combined_tier_id) FROM stdin;
10	Board Game	Club	10	3.00	f	S01	f	0
28	Not required Meal	Service	30	2.80	f	S01	f	0
23	Not required Nicky Barnes	Club	10	0.00	f	S01	f	0
27	Not required TIER 2	Service	30	0.00	f	S01	f	0
8	Quiet Activities	Club	10	3.00	t	S01	f	0
25	Construction	Club	10	3.00	t	S01	f	0
15	Board Games	Club	20	3.00	t	S01	f	0
40	Arts/Crafts + B'fast	Club	30	5.00	t	S01	f	0
14	Boxercise	Club	20	3.00	t	S01	f	0
35	Board Game + B'fast	Club	30	5.00	t	S01	f	0
36	Boxercise + B'fast	Club	30	5.00	t	S01	f	0
3	Coding	Club	20	3.00	t	S01	f	0
2	Yoga	Club	20	3.00	t	S01	f	0
1	Coding + B'fast	Club	30	5.00	t	S01	f	0
22	Ball sports	Club	10	3.00	t	S01	f	0
38	Construction + B'fast	Club	30	5.00	t	S01	f	0
39	Keep Fit/Circ + B'fast	Club	30	5.00	t	S01	f	0
37	KS1 F'ball + B'fast	Club	30	5.00	t	S01	f	0
16	Circuit Train	Club	20	3.00	t	S01	f	0
34	KS2 F'ball + B'fast	Club	30	5.00	t	S01	f	0
17	KS1 F'ball	Club	20	3.00	t	S01	f	0
21	Film Club	Club	20	3.00	t	S01	f	0
9	KS2 F'ball	Club	20	3.00	t	S01	f	0
33	Yoga + B'fast	Club	30	5.00	t	S01	f	0
5	Gymnastics	Club	20	3.00	t	S01	f	0
13	Multi sports	Club	20	3.00	t	S01	f	0
4	Sci/Coding	Club	20	3.00	t	S01	f	0
12	Table Tennis	Club	20	3.00	t	S01	f	0
19	Keep fit/Circ	Club	20	3.00	t	S01	f	0
6	Supper (15:30-18:00)	Service	30	5.80	f	S01	t	5
48	Arts/Crafts + Sup	Club	30	8.80	t	S01	f	0
46	Board Game + Sup	Club	30	8.80	t	S01	f	0
45	Circ Train + Sup	Club	30	8.80	t	S01	f	0
43	Construction + Sup	Club	30	8.80	t	S01	f	0
49	Film Club + Sup	Club	30	8.80	t	S01	f	0
42	Gymnastics + Sup	Club	30	8.80	t	S01	f	0
47	Multi Sport + ~Sup	Club	30	8.80	t	S01	f	0
41	Sci/Coding + Sup	Club	30	8.80	t	S01	f	0
44	Table Tennis + Sup	Club	30	8.80	t	S01	f	0
50	Ball Sports + Sup	Club	30	8.80	t	S01	f	0
20	Arts/Crafts	Club	20	3.00	t	S01	f	0
18	Art club	Club	10	3.00	f	S01	f	0
32	Not required 2 Arts/Crafts	Club	20	3.00	f	S01	f	0
7	Not required 5:00-6:00-Meal/Club	Club	10	5.80	f	S01	f	0
30	Not required Board Games (15:30-16:30)	Club	20	3.00	f	S01	f	0
24	Not required Choir (FREE)	Club	30	0.00	f	S01	f	0
11	Not required Construction (08:00-08:45)	Club	20	3.00	f	S01	f	0
31	Not required Construction (15:30-16:30)	Club	20	3.00	f	S01	f	0
26	Not required Evening Club	Club	10	3.00	f	S01	f	0
29	Not required Evening Club with meal	Club	30	5.80	f	S01	f	0
\.


--
-- Name: activity_activity_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.activity_activity_id_seq', 50, true);


--
-- Data for Name: event; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.event (event_id, activity_id, tier_id, day, term_id, note, space, price, is_active, school_id, year_id, deduct_days) FROM stdin;
81	7	9	wednesday	2	\N	10	3.00	t	S01	1	0
62	4	8	monday	2	\N	10	3.00	t	S01	1	0
63	5	8	monday	2	\N	10	3.00	t	S01	1	0
64	11	8	tuesday	2	\N	10	3.00	t	S01	1	0
65	12	8	tuesday	2	\N	10	3.00	t	S01	1	0
66	15	8	wednesday	2	\N	10	3.00	t	S01	1	0
67	16	8	wednesday	2	\N	10	3.00	t	S01	1	0
68	18	8	thursday	2	\N	10	3.00	t	S01	1	0
69	13	8	thursday	2	\N	10	3.00	t	S01	1	0
70	21	8	friday	2	\N	10	3.00	t	S01	1	-1
71	22	8	friday	2	\N	10	3.00	t	S01	1	-1
79	23	9	monday	2	\N	10	3.00	f	S01	1	0
82	23	9	wednesday	2	\N	10	3.00	f	S01	1	0
85	23	9	tuesday	2	\N	10	3.00	f	S01	1	0
87	23	8	tuesday	2	\N	10	0.00	f	S01	1	0
77	7	9	monday	2	\N	10	3.00	f	S01	1	0
88	7	9	monday	2	\N	10	3.00	t	S01	1	0
86	23	9	friday	2	\N	10	3.00	f	S01	1	-1
80	7	9	tuesday	2	\N	10	3.00	f	S01	1	0
84	7	9	friday	2	\N	10	3.00	f	S01	1	-1
55	15	2	tuesday	2	\N	10	3.00	f	S01	1	0
59	11	2	thursday	2	\N	10	3.00	f	S01	1	0
72	6	5	monday	2	\N	30	2.80	f	S01	1	0
73	6	5	tuesday	2	\N	30	2.80	f	S01	1	0
74	6	5	wednesday	2	\N	30	2.80	f	S01	1	0
75	6	5	thursday	2	\N	10	2.80	f	S01	1	0
76	6	5	friday	2	\N	30	2.80	f	S01	1	-1
89	23	9	tuesday	2	\N	10	0.00	f	S01	1	0
93	7	9	tuesday	2	\N	30	5.80	t	S01	1	0
83	7	9	thursday	2	\N	10	5.80	t	S01	1	-1
78	24	4	monday	2	\N	30	0.00	f	S01	1	0
92	25	2	thursday	2	\N	10	3.00	f	S01	1	0
91	10	2	tuesday	2	\N	10	3.00	f	S01	1	0
90	23	9	friday	2	\N	10	0.00	f	S01	1	0
94	7	9	friday	2	\N	30	5.80	t	S01	1	-1
61	20	2	friday	2	\N	10	3.00	f	S01	1	0
47	1	1	monday	2	\N	30	2.00	f	S01	1	0
48	1	1	tuesday	2	\N	30	2.00	f	S01	1	0
53	3	2	monday	2	\N	30	3.00	t	S01	1	0
54	9	2	tuesday	2	\N	30	3.00	t	S01	1	0
56	14	2	wednesday	2	\N	30	3.00	t	S01	1	0
57	3	2	wednesday	2	\N	30	3.00	t	S01	1	0
58	17	2	thursday	2	\N	30	3.00	t	S01	1	0
60	19	2	friday	2	\N	30	3.00	t	S01	1	0
49	1	1	wednesday	2	\N	30	2.00	f	S01	1	0
50	1	1	thursday	2	\N	30	2.00	f	S01	1	0
51	1	1	friday	2	\N	30	2.00	f	S01	1	0
52	2	2	monday	2	\N	30	3.00	f	S01	1	0
95	4	7	monday	2	\N	10	3.00	f	S01	1	0
107	26	5	monday	2	\N	10	5.80	f	S01	1	0
112	4	5	monday	2	\N	10	3.00	t	S01	1	0
113	5	5	monday	2	\N	10	3.00	t	S01	1	0
97	4	4	monday	2	\N	10	3.00	f	S01	1	0
98	5	4	monday	2	\N	10	3.00	f	S01	1	0
114	26	4	monday	2	\N	30	5.80	t	S01	1	0
108	26	5	tuesday	2	\N	10	5.80	f	S01	1	0
116	12	5	tuesday	2	\N	10	3.00	t	S01	1	0
99	11	4	tuesday	2	\N	10	3.00	f	S01	1	0
100	12	4	tuesday	2	\N	10	3.00	f	S01	1	0
117	26	4	tuesday	2	\N	30	5.80	t	S01	1	0
109	26	5	wednesday	2	\N	10	5.80	f	S01	1	0
119	16	5	wednesday	2	\N	10	3.00	t	S01	1	0
101	15	4	wednesday	2	\N	10	3.00	f	S01	1	0
102	16	4	wednesday	2	\N	10	3.00	f	S01	1	0
120	26	4	wednesday	2	\N	30	5.80	t	S01	1	0
110	26	5	thursday	2	\N	10	5.80	f	S01	1	-1
103	18	4	thursday	2	\N	10	3.00	f	S01	1	-1
104	13	4	thursday	2	\N	10	3.00	f	S01	1	-1
111	26	5	friday	2	\N	10	5.80	f	S01	1	-1
124	21	5	friday	2	\N	10	3.00	t	S01	1	-1
125	22	5	friday	2	\N	10	3.00	t	S01	1	-1
105	21	4	friday	2	\N	10	3.00	f	S01	1	-1
106	22	4	friday	2	\N	10	3.00	f	S01	1	-1
126	26	4	friday	2	\N	30	5.80	t	S01	1	-1
122	13	5	thursday	2	\N	10	3.00	t	S01	1	0
123	26	4	thursday	2	\N	30	5.80	t	S01	1	0
127	23	4	tuesday	2	\N	0	0.00	f	S01	1	0
128	23	4	friday	2	\N	10	0.00	f	S01	1	0
129	3	2	monday	3	\N	10	3.00	t	S01	1	10
130	2	2	monday	3	\N	11	3.00	t	S01	1	10
96	24	7	monday	2	\N	30	0.00	f	S01	1	0
132	24	7	tuesday	2	\N	10	0.00	f	S01	1	0
134	1	1	monday	3	\N	30	2.00	t	S01	1	0
135	1	1	tuesday	3	\N	10	2.00	t	S01	1	0
136	1	1	wednesday	3	\N	30	2.00	t	S01	1	0
137	1	1	thursday	3	\N	30	2.00	t	S01	1	0
138	1	1	friday	3	\N	30	2.00	t	S01	1	0
139	9	2	tuesday	3	\N	10	3.00	t	S01	1	0
140	15	2	tuesday	3	\N	10	3.00	t	S01	1	0
142	3	2	wednesday	3	\N	10	3.00	t	S01	1	0
143	17	2	thursday	3	\N	10	3.00	t	S01	1	0
145	19	2	friday	3	\N	10	3.00	t	S01	1	0
146	20	2	friday	3	\N	10	3.00	t	S01	1	0
147	4	5	monday	3	\N	10	3.00	t	S01	1	0
148	5	5	monday	3	\N	10	3.00	t	S01	1	0
150	12	5	tuesday	3	\N	10	3.00	t	S01	1	0
152	16	5	wednesday	3	\N	10	3.00	t	S01	1	0
154	13	5	thursday	3	\N	10	3.00	t	S01	1	0
155	21	5	friday	3	\N	10	3.00	t	S01	1	-1
156	22	5	friday	3	\N	10	3.00	t	S01	1	-1
157	26	4	monday	3	\N	10	5.80	t	S01	1	0
158	26	4	tuesday	3	\N	10	5.80	t	S01	1	0
159	26	4	wednesday	3	\N	10	5.80	t	S01	1	0
160	26	4	thursday	3	\N	10	5.80	t	S01	1	0
161	26	4	friday	3	\N	10	5.80	t	S01	1	-1
162	6	7	monday	2	\N	30	2.80	f	S01	1	0
163	27	7	monday	2	\N	30	0.00	f	S01	1	0
164	27	7	tuesday	2	\N	30	0.00	f	S01	1	0
165	28	7	monday	2	\N	30	2.80	f	S01	1	0
170	29	4	monday	2	\N	30	5.80	t	S01	1	0
171	29	4	tuesday	2	\N	30	5.80	t	S01	1	0
172	29	4	wednesday	2	\N	30	5.80	t	S01	1	0
174	29	4	friday	2	\N	30	5.80	t	S01	1	0
173	29	4	thursday	2	\N	30	5.80	t	S01	1	-1
166	28	7	tuesday	2	\N	30	2.80	f	S01	1	0
167	28	7	wednesday	2	\N	30	2.80	f	S01	1	0
168	28	7	thursday	2	\N	30	2.80	f	S01	1	-1
169	28	7	friday	2	\N	30	2.80	f	S01	1	-1
175	24	5	monday	2	\N	30	0.00	f	S01	1	0
180	4	7	friday	2	\N	30	3.00	f	S01	1	0
121	18	5	thursday	2	\N	10	3.00	f	S01	1	0
115	11	5	tuesday	2	\N	10	3.00	f	S01	1	0
189	31	5	tuesday	2	\N	20	3.00	f	S01	1	0
131	11	2	thursday	2	\N	10	3.00	f	S01	1	0
133	15	2	tuesday	2	\N	30	3.00	t	S01	1	0
176	6	7	monday	2	\N	30	2.80	f	S01	1	0
177	6	7	tuesday	2	\N	30	2.80	f	S01	1	0
178	6	7	wednesday	2	\N	30	2.80	f	S01	1	0
179	6	7	thursday	2	\N	30	2.80	f	S01	1	0
181	6	7	friday	2	\N	30	5.80	f	S01	1	-1
141	14	2	wednesday	3	\N	10	3.00	f	S01	1	0
182	6	7	monday	3	\N	30	5.80	f	S01	1	0
183	6	7	tuesday	3	\N	30	5.80	f	S01	1	0
184	6	7	wednesday	3	\N	30	5.80	f	S01	1	0
185	6	7	thursday	3	\N	30	5.80	f	S01	1	0
186	6	7	friday	3	\N	30	5.80	f	S01	1	-1
153	18	5	thursday	3	\N	10	3.00	f	S01	1	0
151	15	5	wednesday	3	\N	10	3.00	f	S01	1	0
149	11	5	tuesday	3	\N	10	3.00	f	S01	1	0
118	15	5	wednesday	2	\N	10	3.00	f	S01	1	0
191	25	5	tuesday	2	\N	20	3.00	t	S01	1	0
188	30	5	wednesday	2	\N	20	3.00	f	S01	1	0
192	15	5	wednesday	2	\N	20	3.00	t	S01	1	0
187	20	5	thursday	2	\N	20	3.00	f	S01	1	0
194	32	2	friday	2	\N	20	3.00	f	S01	1	0
190	32	5	thursday	2	\N	20	3.00	f	S01	1	0
196	20	5	thursday	2	\N	20	3.00	t	S01	1	0
197	1	1	monday	2	\N	30	2.00	t	S01	1	0
193	25	2	thursday	2	\N	30	3.00	t	S01	1	0
195	20	2	friday	2	\N	30	3.00	t	S01	1	0
199	33	1	monday	2	\N	30	5.00	t	S01	1	0
198	1	1	tuesday	2	\N	30	2.00	f	S01	1	0
200	34	1	tuesday	2	\N	30	5.00	t	S01	1	0
201	35	1	tuesday	2	\N	30	5.00	t	S01	1	0
202	36	1	wednesday	2	\N	30	5.00	t	S01	1	0
203	1	1	wednesday	2	\N	30	5.00	t	S01	1	0
204	37	1	thursday	2	\N	30	5.00	t	S01	1	0
205	38	1	thursday	2	\N	30	5.00	t	S01	1	0
206	39	1	friday	2	\N	30	5.00	t	S01	1	0
207	40	1	friday	2	\N	30	5.00	t	S01	1	0
208	41	7	monday	2	\N	30	8.80	t	S01	1	0
209	42	7	monday	2	\N	30	8.80	t	S01	1	0
210	44	7	tuesday	2	\N	30	8.80	t	S01	1	0
211	43	7	tuesday	2	\N	30	8.80	t	S01	1	0
212	45	7	wednesday	2	\N	30	8.80	t	S01	1	0
213	46	7	wednesday	2	\N	30	8.80	t	S01	1	0
214	47	7	thursday	2	\N	30	8.80	t	S01	1	0
215	48	7	thursday	2	\N	30	8.80	t	S01	1	0
216	49	7	friday	2	\N	30	8.80	t	S01	1	-1
217	50	7	friday	2	\N	30	8.80	t	S01	1	-1
218	2	2	monday	2	\N	30	3.00	t	S01	1	0
219	33	1	monday	3	\N	30	5.00	t	S01	1	0
220	34	1	tuesday	3	\N	30	5.00	t	S01	1	0
221	35	1	tuesday	3	\N	30	5.00	t	S01	1	0
222	36	1	wednesday	3	\N	30	5.00	t	S01	1	0
223	14	2	wednesday	3	\N	30	3.00	t	S01	1	0
224	37	1	thursday	3	\N	30	5.00	t	S01	1	0
225	38	1	thursday	3	\N	30	5.00	t	S01	1	0
144	11	2	thursday	3	\N	10	3.00	f	S01	1	0
226	25	2	thursday	3	\N	30	3.00	t	S01	1	0
227	39	1	friday	3	\N	30	5.00	t	S01	1	-1
228	20	1	friday	3	\N	30	3.00	f	S01	1	0
229	20	1	friday	3	\N	30	3.00	f	S01	1	0
230	40	1	friday	3	\N	30	5.00	t	S01	1	0
231	41	7	monday	3	\N	30	8.80	t	S01	1	0
232	42	7	monday	3	\N	30	8.80	t	S01	1	0
233	44	7	tuesday	3	\N	30	8.80	t	S01	1	0
234	43	7	tuesday	3	\N	30	8.80	t	S01	1	0
235	45	7	wednesday	3	\N	30	8.80	t	S01	1	0
236	46	7	wednesday	3	\N	30	8.80	t	S01	1	0
237	47	7	thursday	3	\N	30	8.80	t	S01	1	0
238	48	7	thursday	3	\N	30	8.80	t	S01	1	0
239	49	7	friday	3	\N	30	8.80	t	S01	1	-1
240	50	7	friday	3	\N	30	8.80	t	S01	1	-1
241	20	5	thursday	3	\N	30	3.00	t	S01	1	0
242	15	5	wednesday	3	\N	30	3.00	t	S01	1	0
243	25	5	tuesday	3	\N	30	3.00	t	S01	1	0
\.


--
-- Name: event_event_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.event_event_id_seq', 243, true);


--
-- Data for Name: fee; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.fee (fee_id, activity_id, tier_id, price, school_id) FROM stdin;
\.


--
-- Name: fee_fee_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.fee_fee_id_seq', 1, false);


--
-- Name: hibernate_sequence; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.hibernate_sequence', 2940, true);


--
-- Data for Name: invoice; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.invoice (invoice_id, invoice_no, parent_id, student_id, invoice_date, amount, description, school_id) FROM stdin;
2020030001	1	ThiaKunaratnam	101	2020-03-03	171.00	Invoice for Thia Kunaratnam parent Thia Kunaratnam	S01
2020030002	1	SamKidd	166	2020-03-04	84.00	Invoice for Thomas Saback Bell parent Samantha Melanie Kidd	S01
2020030003	1	OClifford	167	2020-03-05	62.20	Invoice for Eva Clifford parent Olivia Clifford	S01
2020030004	1	OClifford	168	2020-03-05	391.20	Invoice for isaac clifford parent Olivia Clifford	S01
\.


--
-- Name: invoice_invoice_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.invoice_invoice_id_seq', 1, false);


--
-- Data for Name: invoice_receipt; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.invoice_receipt (transaction_id, invoice_id, receipt_id) FROM stdin;
\.


--
-- Name: invoice_receipt_transaction_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.invoice_receipt_transaction_id_seq', 7, true);


--
-- Data for Name: parent; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.parent (parent_id, first_name, middle_name, last_name, po_box, address_line_one, address_line_two, city, state, postal_code, country, mobile, phone_no, email, relationship, school_id) FROM stdin;
StAndrewsSouthgate	St.	Andrew's	Southgate	Chase Side	\N	\N	\N	London	N14 5PP	UK	\N	07729033736	sam@datam.co.uk	\N	S01
JaneBeeks	Jane	Middle Name should not be required	Beeks	15 The Road				London	N15 6TF	UK	\N	07729033736	sam@datam.co.uk,	\N	S01
S01parent	samantha	Melanie	kidd	po box 444	95a Vicars Moor Lane	Winchmore Hill	london	greater london	n21 1bl	UK	\N	07729033736	sam@datam.co.uk,	\N	S01
CharlotteTurner	Charlotte	\N	Tuner	184 Chase Side			London		N14 5RF	UK	\N	07729033736	sam@datam.co.uk,	\N	S01
athulaperera	Athula	\N	Perera	wts lanka ltd			Ratmalana		1010	Sri Lanka	\N	0940112633162	athula@datam.co.uk	\N	S01
LiahBarb	Liah	\N	Barb	12 Tha Road			London		N21 3ED	UK	\N	07729033736	jayasinghesamantha01@gmail.com,	\N	S01
PrinithJay	Prinith	\N	Jay	45 William Way			London		N21 1BL	United Kingdom	\N	07729033736	prinith@datam.co.uk,	\N	S01
athula01	Athula	H	Perera	WTS lanka ltd			Ratmalana		10101	Sri Lanka	\N	1234567890	athula@datam.co.uk	\N	S01
JamieVine	Jamie	\N	Vine	15 Old Park Road			London		N13 4RE	United Kingdom	\N	02083514087	samkidd1234@gmail.com	\N	S01
JaneCarver	Jane	\N	Carver	15 Old Park Road			London		N13 4RE	United Kingdom	\N	02083514087	jayasinghesamantha01@gmail.com,	\N	S01
Ruth-JamesSouch	Ruth	\N	James-Souch	23 Long Lane			London		N14 5RF	UK	\N	02083641167	jayasinghesamantha01@gmail.com,	\N	S01
SuzanneDeJarne	Suzanne	\N	De Jarne	15 Old Park Road			London		N13 4RE	United Kingdom	\N	02083514087	jayasinghesamantha01@gmail.com	\N	S01
mariwarby	Mari	Mirjam	Warby	10 James Street			Enfield		EN1 1LF	UK	\N	07932657011	mariwarby@hotmail.co.uk,	\N	S01
Parent2V4	Susan	Kate	Williams	95a Vicars Moor Lane			London		N21 1BL	United Kingdom	\N	02083641167	izzykidd1233@gmail.com,	\N	S01
Parent3V4	Sarah	Kirsty	Craven	95b Vicars Moor Lane			London		N21 1BL	UK	\N	02083641167	izzykidd1233@gmail.com,	\N	S01
Parent4V4	Josie	Jane	Williams	95a Vicars Moor Lane			London		N21 1BL	UK	\N	02083641167	izzykidd1233@gmail.com,	\N	S01
kusalp	Kusal	\N	Perera	57			Colombo		101010	SL	\N	0112633162	athula@datam.co.uk,	\N	S01
RuthJamesSouch4	Ruth	Kate	James-Souch	36 Oakwood Avenue			London		N14 6QL	United Kingdom	\N	07984487728	izzykidd1233@gmail.com,	\N	S01
MariWarby	Mari	\N	Warby	10 James Street			London		EN1 1LF	UK	\N	07956338356	izzykidd1233@gmail.com,	\N	S01
Maria-123	Maria	\N	Joaquim	10 James Street			London		EN1 1LF	UK	\N	07956338356	izzykidd1233@gmail.com,	\N	S01
MrsSolomou	Paraskevi	\N	Solomou	25 Merrivale			London		N14 4TE	UK	\N	07990560473	maro.iordanou@st-andrews-southgate.enfield.sch.uk,	\N	S01
WilliamWallace	Willim	James	Wallace	95a Vicars Moor Lane			London		N21 1BL	UK	\N	07956338356	izzykidd1233@gmail.com,	\N	S01
KirstyS	Kirsty	\N	Saich	25 Mayfair Terrace			London		N14 6HU	United Kingdom	\N	07770777338	kirstyrome@yahoo.co.uk,	\N	S01
andipandy	andi	\N	panayiotou	84 park drive			london		N21 2LS	uk	\N	07930442150	andi@design-box.co.uk,	\N	S01
PSantoro	Philippa	\N	Santoro	28 Shamrock Way			London		N14 5RY	UK	\N	07800757204	philippa.santoro@gmail.com,	\N	S01
StephAdam	Steph	Sarah	Sprakes	15 Manor Ash Road			Suffolk		IP32 5HN	United Kingdom	\N	07729033736	izzykidd1233@gmail.com,	\N	S01
scolq	Sue	\N	Colq	53 The Chine			London		N21 6DD	England	\N	0208 999 7687	sushilac@datam.co.uk,	\N	S01
SamKidd	Samantha	Melanie	Kidd	95a Vicars Moor Lane			London		N21 1BL	UK	\N	02083641167	samkidd1234@gmail.com	\N	S01
Maro122	Maro	\N	Iordanou	25 Merrivale			London		N14 4TE	UK	\N	07990560473	thia@st-andrews-southgate.enfield.sch.uk,	\N	S01
Donkey	Donkey	Kate	Doddle	95a Vicars Moor Lane			London		N21 1BL	United Kingdom	\N	07729033736	izzykidd1233@gmail.com,	\N	S01
JamieBell	Jamie	Kate	Bell	95a Vicars Moor Lane			London		N21 1BL	United Kingdom	\N	07729033736	izzykidd1233@gmail.com,	\N	S01
June123	June	Kate	Davies	95a Vicars Moor Lane			London		N21 1BL	United Kingdom	\N	07729033736	izzykidd1233@gmail.com,	\N	S01
KennyG	Kenny	Kate	Gelato	95a Vicars Moor Lane			London		N21 1BL	United Kingdom	\N	07729033736	izzykidd1233@gmail.com,	\N	S01
mahelaj	Mahela	\N	Jayawardena	56			Colombo		10101	Sl	\N	0112633162	athula@datam.co.uk,	\N	S01
ThiaKunaratnam	Thia	\N	Kunaratnam	EN1 1RH			Enfield	London	EN1 1RH	United Kingdom	\N	02088863379	thia@st-andrews-southgate.enfield.sch.uk,	\N	S01
C001	C001	C002	C003	1102			colombo		5546	sl	\N	615152	jasinthawts@gmail.com,	\N	S01
OClifford	Olivia	\N	Clifford	35 Wynchgate			London		n14 6rh	England	\N	123456789	oliviajclifford@gmail.com,	\N	S01
\.


--
-- Data for Name: receipt; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.receipt (receipt_id, reference, receipt_date, parent_id, student_id, amount, description, receipt_type, school_id) FROM stdin;
\.


--
-- Name: receipt_receipt_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.receipt_receipt_id_seq', 1, false);


--
-- Data for Name: school; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.school (school_id, school_name, postal_code, school_address, school_email, phone_no_one, phone_no_two, is_active, is_deleted, school_logo) FROM stdin;
S01	St Andrew's Southgate Primary School (CE)	N14 5PP	Chase Side, Southgate, London	sam@datam.co.uk	2088863379	7543628829	t	f	\\x6956424f5277304b47676f414141414e5355684555674141414a594141414357434149414141437a592b61314141414141584e535230494172733463365141414141526e51553142414143786a777638595155414141414a6345685a6377414144734d41414137444163647671475141414a4e2b535552425648686537503046674633567554654d6237666a5a3978394a706b6b6b325469626951684953514544653551704b56594b62536c314175466f7155553132496853434342754c736e6b37474d7578772f5a3774387a39706e344e4c652f6d2f766e5a5462372f332b37354f564d2f7649586e757452332f50576d75766a567557686631662b6a2b5a694b472f2f35662b6a36582f4b384c2f34326c346a685364416966694f473459426b6b5163477a6879613851776566774d76546d2f36384a4d57626f455045614d394548466b5753774465434a50386c6a42714f43424f78494d657942456e687069556e5249376e4c5657486c67784a4556354a3876394b45424877316a42746855667967774f4c42485848534a62534e49576b4b5977412f5766746e77366668694e4356596e31646e532b3865707232536c706c6d71514670353078306b527771744f2f492f722f50386b676469414f556834535245436b59536961786844657450547a6a6c336b533874465363342b347668303342454b49756835727147422b2f37306432333375356942557a5644524d554443717a46653462632f792f5a45747553486732667969474e6c6b366b6f6765506e5873797575767a536b737850422f6878566165714b6c72763450763376736a75747658762f4f42373174485a53464a51305058704438564150356b50394c424937523444714833706b3470754657386367524e2f333078382f3836636c5656312b5a5831372b62784b68717459644f664c634530396375577a356d706466696654314d365a464970385030734f52357941304f4349736e44514a7a454c6548794d706e534a56484d4d5a4e715a49416b6d52467161704b6b555142413468315342782b506c51396168426c6833346363797762527056674f4f45695251464370787277466c7743767a59566e4a30674336506d3462463071796d616961477354796e36597146365a5946324148614d645134416f6f4a645a6a6f47765a466b797841462f72575779424147304e75304837524e4230774348774b722b42344e4e4d7753644a424d34536d303143356f70413453413164526f632b345a614a7a71614178636d3644514c544b6371626e666d7a462f2f79386d75765848724e74646b6c525268466f377250676f596a516b77786d3036636550595076372f7333485058762f3536734c4f444d79304b654962594334306d4e457145506b4d596f48586f41444366556b784d45336a4d775773304c5245576232454d5157694b79674134773347514a667a653973585156317355364e67437464554a704c7a41414d514d387a2b4b68684d477942545942462f595a314555625769476f5a6c4f33716b72756f356a444d3870617079675146514b4264684c30776954494948724a6b5759344468516539466c6b686644375176426831392f59717352564939514978416359434137696c49314856414a484f6f414d426d575551314b5559316f5444414d79674b564d797a6356456e64514a5554704d4642443641754d454c6f693070524b515835397a332f357a6666657676437136374f4b437243574e4b7566766730544247654f5837305434382f66736e6952657666654433553263575a3572644671464d534d4145595442744968437776394166434a64586a6f61526c5a33556c6f686848347a526c414a2b427661594a427a7a336456533352514965434f6b7a3841504d324761684252707657794738516b46385171374a516e614f7a6b4a3458514e67624f454d54714c764b41724d526456456d676345723141736957717952516a797730335373457a643070506e6f767252693031667677584544354961656f38495632575a59466c4e302b4137426a41356a7363697358544247656e7133726e2b53793934466c6e524e416b756f3445496f666b5777576c2f4c304a66587536502f764c696d322b2b74664b4b4b7a4e4c5330475868366f664c673150684562446b534d765050336b7967554c766e7a3939566876443250387251684a47596e5177696d54684736414c676f756a387177516d62616a783939464f4d5a4c6356464f6e6a547a6f3267324f714f7a6765433834466e70715744624a4f576b6551686d4142494474574f75494742444e4572794a6a4567566e77537a415171417a545455774864306562716b37774171624c4a714672686b4a794e465149566d6758436a4e4a6a4d5173436c55394a4b496b47373746444e51413034434449523343775a6b5442454f44776f486267504e415161686f664e2b32375a2b2b2f5136576b4c524978465367343942736b4a59423667584f57314459623474516f556850647661505833376c7a5466657647445635646b6a526d44303050574854634e53415243374163454969523970774a436e2b512b4339392f2b434834546a5562446f554266652f7676662f4a6739356b7a4a746766525249304465354f785577566767644e366d43584e4b5844682b415357645943752b51346e4f56774a6c6c5938466f57793570514f4e62694f517a795558444f676f414c446c5467464969347747714f3765337633723531383042374f396769664569777645485146693259634d42425154575944474e5346425444666a567079767136594d6b43502b41346b2b66514b38645a484774776a453767716d585348416465476c7a41746b306250333333336644415147436758314f55727a3078366a3577316e596f66307351785130444f415a734177332b7a36776242673358697048745173693252666733386b494546704d73536267426a6f31686166426a594a494e4a3436762f6576627255316e34724534696a4c4151594b45774b5a43424c574c6a69634c66456871474d536262777236484f4966436f4741534d416130525873547a44305378573553597067474c6a386e683362332f7672582b74506e776241676548776f6141547441496847614e556e41516a4e516c634a7769464a4b476f42436f617844614958485a423768594f634e5165614a694b34307179594a674f7a6f42684d59494968384f6e6a6831372b376e6e67743164504b697a72676b73513448767451445a4154494144775275347839493647756c5236356e364b4f7a6f32474a6b414275596c3633477a5558734a6d754433332b4e53487567742b786851762b52446431525a4f676c366f5945796a38324e37647a7a2f307950485076694a43457031516d5952437154706a5967784f5542413843474165686d6d6d7157674d4e45395372626a4d513042564d63346b475174774c57425a322b2b61634257537473432b63464d30614d30695252574c6949465464562b393870726333506273517a2b4e74485a68436455494a78773452316b4d67394d4d614130774634564d6e4e497351744a7033654a417a6c436243747948727a41634241586d72466f635476414579654755514643555a6e4b7151557361584d6a7348747a387974755033763544643078794a78516d484575426c73516b547445467a584a6f6d457542676773496d50384e3451517538414a6756345a68674865324a5a777444632b5249685743397467322b493863715331433277724272794644424c65426b49646449505446577a7665652f4b3564532b2b62415443684735794f456c446d4147444d53774958704270414e446d534d705356424150533143597045467149455a693955654f76765438387a2f3730514d502f65444f313535377571572b58705656557a4d745751627a415a4f55517046663358305048677154735667717a5459645045514138694559414336576f69484e304179496a595a7557497242674e4d6c534e41534e535a6275674867785651315656494d4349454161426c49366541543848326f3042686f47494c5a596d7648737a2f352b65612f667042696b717868326a674164636f754b49577941566653436f635938682b4555686b496c6a62725141332f452b754751634e7a704f6a79414e615149305759343538534569577947674166466b4c6550674e6a7737487437333134594d4f6d57486376706d6f59354255364245547765736776512f33517932676f334e766530643357337448596548543337672f66664f764e56313439636667496a654e5a6d526d4a524f7a5538574d51593146796956797147653376322f6252476e31676b4937486e4159596846617a6533656f75346451564d436f61455153314d7645614d6846675a4761446d71426f433179797059704b5849734467796d47564162454b696d673366524d59724141665241536b69424634324c6f62623231532b38314c52374878394f4f4657644e6c47505341787763524b7a6f4d5a4441626261766a375a2f623868754c4c39463056462b2b427343616e44304f462f6e32546a784f35646131642f4f47315535595a33336f373339663164586b6869476a51525a47746e5776594637494e764f756d5361563233434b636a774a4e546c793235354b343757623858556e55634c4d2f6d4150684b5456643362643232626632476e6f34754d527154525a46334f435a4f6e587a353156656c5a6d655349424251496f6f446a326a71574349754f6e4869304e70502f2f4b3758377330795733494f6b5a4c467145376e5466393468646a46352b4c30597a42454c706853676e4a78614e38774a4a56434b70774e55305341344f4458514f3967394777322b394e795568336554774f74354d68575134384e33414962466157616378734f566d7a397356586d67386639596d47455974445369737a594b544a506b486e6b4532686771774d4859435661515341674b52306b306b463663724d665044466c393535372f324679383476727134477a54704c477059494a6633597a68337250766c34386f694b6a652b384c51344d736e2b6246354b67765569454b446533765369536e7830623062586767777a4445517145684c5455466c4d6d4d2f7970466155332f4f6a65777372524670784b51475a41616f59455a714a4a6371533750783550534c4c4b6b325261626f375842396b586a6b416a72756d6d41586b675154736f6b676248566266763050765050425673724d554865314e7751796559754957464d574c47525264666466633954497066704369476f63454935486938706236327666344d703247392f62306e61303872686a5a397a717a534d6150417477676556327032427338367746346444476359476f415555314f4f3739333737745050687072626d484169797941705451464a742b7642704c78734a694c784a55566f4d774a3148764c5476306b71534e4b526e763654563139393539313346797864566a5a7834746d4c6b487a6b6b55654744762f624244437670373339544831646c732f58644f716b4a435a634868647748304b536e5a3152504d685031306b414a70416e6742496a70772b7542626f4836547167536442386a655a6f44544e777341784e6a5151443357306447656c5a666e38614e416d4e6d524d5965426d4f3456787562356f764e54736e4a7930725733433663424157535269672f36676553744542353344673951785a6665654a7033705031566a6843473942526b43436832514a6d754c592f6e425178347a7943654d74476f52697162724730717a44355853373351614f4f627a7538524d6e4c6c79385a4e794543626c352b656d5a6d616d706152544e51597568456b42506b4768716b656a754c396139392b635859693074724b493463517a384a376759555a4e564e414a716f7a636b4d7153746b4a7979464132684166774a584569554e5973694944326d6e44784b6e79794c6454686e6e376673354f6d61777649795831596d3074697a6f2b47636237742f70475151547144704d7154494b64373879654d7874794f714b4c4b6941384c305543797536494251534a494359472b4864736f436a6b4136625445696179565954535556515a6639697077615358527433725835786265616478366d52497857416172524a7361714f6f6e6a4c456279647545776b6755416f644f735174434777656f785374636f5754644553547179613266666f615065694f77564c55596a5a5a4b6e4c63596847533546312f723764712f37724c33684a4155576a78735554635a6c6d5864374961306566633763366376506d7a6833626d4846534a63376c625a59786d497046554132346a706a4d6d5a634e304e4b336559394735392f6e57686f54557549506c5868644a43636b6d4231435352734d736e684f687a314379416d4956414d4a71744f692f5241663055524d696f526b464761662f6f6c4b7a475041394a4b304431633163417144556873494161634e5130547a674465534b62326f4e6561716274545532372f31532b75765073756232457534585048614477493249346d4656584456644e4a4d70794f4d5159613277536c68582b4132734255774d6d41755348744e5579426f6f377533766e634c783670333762466b6b5243316c3034365741416551417a49625471467141677345384337424e6a6f4e3034474c6671646647554b424b68304d397675314d6644424b797a414c384943785246654f6144494941792b63784b74545339647839503433577432474247436471666c3751347a4c34423151504f4257456b69475957364278426c794549586d5345414274784351386d6e6a723937392f2b6248486774326468493430306e615063424c5947413061696679465058674c76594d2b63686170696970346b51526d6869786435546d4a495976476a72373031707357586e4635584656553847414941534a2f43387a375677445359596b514f6d4542456f5038467943796858454f7832416b4170422b314a534a6c3939366b2b5a676f77536d38367a4a7335447049555375417649476b49316d474d446a4943624149665466416d74444971524a436c4166413667774e506a6b72333678376431336c62344249355977496e45624f427141566c55434453474438674c4c774b494279724275546f33483555427739637576356a76646a4b6f426c78484d413847423842694b464867775548436454707757757762656665366c7a746f7a65695342697a4a486b6c417871676570464959476951684c4164787061514265354d45516f527271774f43726633683039385976315567495532544949372f4f64314869594d735055677a55492b52686b425168737a51674c344a6f676a73456a5763486457586b35416d58333348627141587a4d62654c64546f6f6c6a485161414e694f304c31414b58506d6f596e51705158676a39413967526144433248316e414d356e4b3643764976766647476c4c4a6956574244696777426b695a7078694b67682b415a675639413047316b66304d6c365a464e796a4a705132634e485976484e71315a7657334e783548324c6e7351484a6b465245304e7a413746477051446f4e7a664d6e5644675a4233617665655931753273364c69414d45682b3959684859453841483676674a77684e707345712b4743596a587550627a3567342b4462563257436f614e73576a47794659707a4e4a784333345079414d79436c325651543674523039383974707278335a735a5657464d5453654248485a30326d6f39584432554f4f524347327467743668506d4b6f7634414a776f5a6d7552316c6b3670583348496a6c654a4463516643446e4a6149474b51735732464b4446447644684c4771595744446b4231435a5153704a314f69474e61757073662b795a703863746e4c2f737075743870555569512b4d38442b674d6a5754626b33744a63496f79506e754d4752585541414238707155717151374f43536b6a695556617a6e7a35326d76622f767175456f74546b49707249735053426c7146416c64446267387332774b6e52706d47484e2f7a3256716a663542505341787742426f454f4967415a686b71695364417a434244794c4a567736486857435236654e3258377a37356e4e7733674f73475243796f4232704432545a414e4d4257304552646f53306a304e79383773575831722f32756b755438576a49695a6c2b6a69554135434b4c52534b7a4730386a3877505232493456546b5676544a527173693633534a4e35343675756665674230754e363936505633623039494459306449636d52344552694f334150445152637459304c424861397365784850706a577070712b4650544e4d5063736d32376b4a724b7061534f6e4472747a7038396e466c634644453068615a45484e635a4368417152414b4b68524343776f46746a4b4454794c44674c36514b556a534b61796f6d4a675351636a533265633261563337796b34474f446f695a344d6f67564f6d79614f6f61686a797272686c36494453772b7433334f6871624d45584e544d7551444430426b4e504a3030346e52624d5166794f53524473635544556f4751354147634348616834356450435a507a7a61333959474c45526546306e5141442f4e676c6830465466314d346350502f66777736663337485742426b54436670346e644655523435416251464e525157494464776f4373326941334742656d456b4a677348537073415a504e7361474c6a6f3671757675664e4f66323575566e6c465932665876695048414f6c514445413469415a776f6d6b61426a444151435a77746a517345534c647353426e7349574138527758436f5154735551696f567877386157673938634f48396d306264766466336838334b795a7573444743454e6d536448534d5a595346596b6b494654427563696b6f42356b6d2f41474941566b397544353743446a4948464f312b6f504858376c3063654f624e7a734943684356566c776463687a495259616b47575a317135745779476b4359496a45493151667266474d304646316b68535679413055794135485a77386753736b344174645a334243414b7a434844312b394f55582f31782f2b71536c613661715541426c4e454f4a78784c394137732f586676383733376632396a49476271485a65454d454442614d4a414d676e426c6448456f6b5047614445324b69515147655156447855776c624b6f68694e707531385733334677786339616d48627636417947534634724c4b31706132335130444553774e474f37586c4145714151715171396e53634d52495449646d2b2f51414254685456794b693670754f707a75535a4f6e595144624b573748706d313170327358585856463262524a6d7074586e5779434e425863354a774f54565574452f77614571474646696841735375302b774d73676a704a513663306c564b56356b4e48506e72786c666154707a6c494151486632744f746d475777444c43584744392b7776545a63386f724b2f504b797779504d304a694373736f4b425179446f63374f7a637672376734663252353371694b63584e6e6a4a6f787557726d354f715a552b59755775424c3959644341527a694e37686677795155315746696539643939636e4c72356e424d4b767272476c417870724d2b42444462655037757143576f774375617a52465552776a575871434d465558782b656b6a35342f652f6d3156362f37624f33682f596579383475686b6150486a4b4d49426d6435434e4e6f49424470677331442b475058667059453065682f544d6a6e447a5544493078636c395473744378644d61644e6e4d7169744234665654466d2f4f6a786131642f2f4e534c7a31336f76796d2f75764b70523339586d70456d5238455930486f5a6545557a765241443061514164414d4b556e4945554f3077795a4c41575a306e61446b51736d6a324e3966642b724d2f506c453064597171796753795545615759344c4c653875646434554f312f4265502b6c3047466f43306f7841642b2b7564527649514377314f33503272546354736d68784e4f5a3157634542496a4d44695639524972456f534e6d666d7a4d77304a666d39696a68474f74305066756a42787233374d46454f647a545535366471346b696f412f4967354c7451706144413469793351627150596a575544584e6e2b3776434133694c716443345448537575575771795a506e30316c70782f6164326a5a656563526f71626862505759616765594b75416e69414379546e413237314264434b414e5277422f53384f79517153567146664a7276457369775973465430394e593267534d496b4f6c7661547830374b53584553447a754c3871646438477932333538482b3178796f41694d64504a3835447651534241686d6a726456496e554b69334379416741314a33476b4b586b696134597233394b52543778352f2f3672302f2f77584d48614b61724b73633730425243434e32486a35387879303333587a6c716c382b2f75697a72372b3234636a6879696c547377704b4e6e377835554d5858766a6a5732373635592f752f65325037307534426431534c5272483349496e4d393256356f2b4751366d5a475a716d685872376e37372f522b306e61737949534d6e71754c4b4b534741516a664b68695170513061465732533145725955326f30504d414565714b77703058545355394b4c3833373777374d7a6c5339333532563074546271754e3578757745674f6771552f4c54556e4b77644c69436c655077384149736c442b302f79395378704f414e736b5039324e3758307433563653626135746c6256564e6f6854463230734c577449362b674542713265385047707671363773374f4f5973574f4c326551446a6f795571486b426b4e527a524a6f634454515451484c30525445497341616d67366f454745305965514f6759534e6b77444142414a68674163593841634e62573772793861445a654e476b5577614d6b516f416b7048484d493775364f396f48427763364233756247787336366875616a783557657763464148306b546f5668344d425a75372b364b78554b53707255304e6255306e716b39565450593035755a6b51364a5555643977316676727a3636637863575354674d4536326c51414d574b5076573764552f5353564472734b4f68695434654d3167534568694c5a4b6b343670752b64795a49797157585831466c4c41457763577a7776597676757073617156776f717969334a5871363272724f464e7a4f722b30625030373732694a4f4d7451633559764f316c374b722b734c4430336c344a55364f786f4f46624936675370596f784a67416f444670634d696664796968452f65664b414a49585565506841335a484a7336595665314c44652b714e74746a324439627650566f7a385a71723539313570316c53456343634a73374b6b7370514444676e4771655668494c4759457841686178704361626c6c41672b5162454a6a41492b6776777357665869704e5452736537565637612f3861726530306d4c4d6f5879617975764f482f716a4f6c755663735a694a5745704f78416d4f6e76626d383954684a524a6462464a344b5a73566835516a337a326f656633662f4c4e542f2b7a59732f6550436a4a3535764f58544371526d6878727256547a2b35352b4f506e4a4b4d68614f6b6174416b4535643168654c694a414f766b4b2b6a5a4138554377334a676b4b42682b644236316a4b68526d63535867545444592f647471536578373054353331347076766e3935356e41706252313735384d706c53334972736a3766397045596147733955337669794347635a4e42774d61615946694167325148515269645a375777586b51494e5234516f454e7175424b6b6c5741314a47545973484f6a7550625a766638335259367175566b3063662f3950666e7834312f61542b2f667632725672796f534a454e696d7a3568312f7a3333462b59584a4f43636c4a5341436a6b3241366d637a2b4e444b785873435745637257314169796a516c596163446d706c49684c6a5353724c6c2f4c4355382b382f647a7a725856317766362b7a71364f423339382f2f4d762f536e4f6b324765436a4a45544f44374c53764f3853626e776d6d6e536a415233596844503333656f43724656446b6c4d794d724d2f4f6352597337327a762f384f4f66484e6d39567942704a5a37774f42316f4f4d362b494677587857646f41773677432f4a4d4536465730447561672b515559396949615967634539436b6c537650662b432b6579654d472b76682b597153307062477872364768766f7a54524e6e7a5330644f6672496f614f67376366334835446a436167524b6f655354435568437149652f697363366644674443724a3559464a623834776a4d2f744c69346f324c722b4b357067796974476c49346152526c6b55306437614e73576765647a4d724977677536755052506f364c6a716c707333625078733336357436616c5a6b63354f775036474a484e676b596876614c6f636769513651472b2f4a6e766471614c70656b7a4d63486b5062746e6530544d34666647356757683033734c35336f745763437a72414c45707169374a6b57436f7662553930646b5a36656e704865695849446531724a69753559326f794d7a4d4c436770725a347939636a4f585164336267393364767368706d6f4146456b6c4c724c6b333345444f5845694f614e72343254495653794755634757574a62672b664d574c706c7837714a4478343455454b71513556383066384832747a37365973334835615048384c6c354659544f662f586c715232374157464e4844385a5942524e3055683671467551594e6b4959486732394c63306e4271417851694b4a4b305171525961354951737261796b395053783477326e547065576c7a6c53664c52543847646c314a39704c43737642793057534a4b68364f65666574715a6e6a35333161584655796633515a4c414f5441413347444a6143344450434e613851785743487069677962555a62674967422b614946674c6832496c4a4637484f6b3758626c69396573364d36664d586e7a4e352f757a4369654d4b706b34597357447571484d577a4c70303157563366482f526861757943386f31536b67744b703279614e48384b792b2f3449627272726a6c356855585878694c786261382f3448633130394a476934716c4735432f484e774e6c4b30532f4b366149496631364139396f6f4b652f41464c53756b545a5a4c4d4e536f632b59767565374b78754d48362b704f2b5879754e49396e564d5549594d36323754745758486f70526e4f7057666d6a52342f647476354c534670476a6869425236496f45554a4a43716f667246433365586a324e4677526f6e4573573472774873636b556354394b5557566f7a6737626f327348416c5a4d386c53575258466553564679383966496441384c686e70336c51706c716739644342725a506b502f2f4259336f5471434b67324b79686f7770693049514d6f766f6f524d6c7244396a574967494a47536b325477776e574d4576534d76582b6f4e6e65597a563350486e6e58663174376170684f68324f3970376577796472616c70615031753338594548482f6e6a6e31356d665a6b33332f5041764255586a5a6f7838356f663344562b786a525858753765725675652f396e507246424936526e495a49515569714d55565942596f4b496c684b6844396855524c6b34325a73676667447770786352466a447754434e7a7736306375752b384868704e2b36746b6e4345586b464d5549685a304f562f576b79515a46566b3666626b6d79792b6d654e3366686b663048432f4d4b536b61507756787558644e4d43496649444a45566f6f485a4a4550506a6f596a516c416c307a52706d74594253614a6a74457755557a557749342f584f3233364e492f58427a387a54614f7a7036742f634b436a725130414a2f426b323772315470647a38383574375632646c4d763177434f50584844393951624c51614b756b7152473442616b4a47675145613151537a495572413442516768544a493557323274616548445137334357706d57533454675a69762f757a682b75667649357a7354646a454d4d5252744f31656d6d636430744e2f2f324c792f4f5772623864467437334d493861526c64445933624e323135387547486e33336943517070417935514a486864585a4852716964514f4a524344463175364e4c774d3435564e4e57694b4e6d795648676c53633776652f623939365a4e6d38594c334f6e474f744c42316a6655487a70796c425a636d4b514d39505a4b717472563234554c416b67715053757a754c6959637a6a516942704a4a684969734956414b796a423753417339713859355236754b34596d5552534656725543575a6a4c356349304e52514d395062313174585653394559664b7a47347a30442f624b716e6a683530734c4a324541514d50327375584d4469566a66344b416953327658725a7578614e48695379376855314e464570637755374930676962424174416f4c4e4c396f59493844356f6f787967436b67397741675975797279716334704b5273556a6d37657466754556546a4f6e6a5a2b3434727a6c4679362f594d79594b705a6e6a7830374b6f714a7a7061577a3964382f4e61727236392b3838326167346563444775704b6d465a396c536b4362585a74374f692b704d753770754c456a6775797a4c46735a4a706d43774c49737946354f474b4b394b7a7331726257784a6948425330597577596838505a584e2b416f58746b73494742775a54556c4132624e6f41547767777a324e63666a6f53374f6a76447753436553446963447043634c554930396f387538753853495152394e466547386e4a55774e6f794d6a4d78416a39383949684a34763268514d655a46734c454f707161584837662b416e565451304e616b4b715033696b7166484d7458666537737250624478354d744c5a74586e392b7241697a6231343552555033437635334b724c7961536b524751414878696b7a416964496d4d45305a6b41437347546f6c66674f7067707548444c63444b30486f353456644d566c6459392b384c785439655a506630416348465a78416c49345052465631363059745646563939773366647575625668313136357263646e6b756d634130536f473772744e4f333637577154395a73513069474a743747784b73734337347a496d75567964386f53563170342b58302f6e4c35693661597447773775326456302f4f694f6a5a735758486a6878476b7a54782b7430515052316d4f6e444530393937787a31333735655377306f4971786f3376336c49346330647a53644f546f555241716d676e5430644a5359426f4b72765a6338646e5463455149777250444f357068675161425a69556b63614372733658707a4f33332f4c4338616e544e30654f364b4c2f38346b757a35737965742f436365435161362b343564756851586c346535654372706b2b4f6448596332374974324e6c5a4f486f6b6d5a6c534d486e382f55382f5157646e644954447a7052556c68463468675644535470534a4334494734536c6b616a6f42436f78544a5559692f633663554f7a5976464d687676386c5a666666764b4a595030706a464237657870323766727179556366376d3172325048654f342f66646a7331474d6f45777776466c4544594a5167344134464e54316156724262715230442f6130634b562b66426b426b48342f4c32793072706a476c332f2b48332f7370794974303363386e43445a393866477248446a6b594c423437626e54314a4b386e3563434f335639382f67584473756574584a36646b33466f37343749594e2b5744657558586e7078356269784a7734664a464a54435a4945554a72304c79413846502f2f58534b455274676747386b502b534454544968694a4a467765747a6a4a302b61755742655633504c6a693833644c5a336a4a34304d627530744c71366573756e6e7a5855316f32624e42456e69636c7a5a38454a6e37377a312b2f666377396867484c71665a4851674a4b34354e5a624a38365a6b31425552566252384d6a513152426f517373306251443154634563624d5251346f594366676b336445725843466b366666545173332f3437616d61493678416c4a546e72626877325a6e616b77653362553330396e6f422b4971796a325964424b30706b4a41616743612b58574879457344654a4b477247386764557077775a2b6e53612b2b38592f75785133464c69347478763964646b4a757a36387376303978755a305a6d626c6c465763584964392f3661337464593146704b5a656564766d566c782f63762f666739733259716563554656534f4877755133564a6c535a5a30644e4d634972534777335a6a5a302f4446434663486f6e514c6b414d7939414d50584c304b4e37726d5442316369775157766670327279636e4d7963484938765a64796b53647333622f4837764b50476a7256594a6a4d2f4e38766e783056703475544a464d646746426d7a39412f58663547526e33764a6a54646d357864514a49506d4d4a4a572b4c5568666c4d4d3238504b684b6b4c614a30554771496a4d4a3669634533563558684857394d727a7a2f5a3374666d7a303570626d335973656e4c514663486f326d30704c68784e4e79436134694a434e4d6a4c7a7055327a6346586458474d756976695947376e54526a31744a4c4c78324952542f65744546423030555579544d6c42666c4f484a383470677069504f4e796a7867315a7142334942594b463557553441512b633937737a7662576e56733235325a6c2b444d7a6973724c526f305a67304167614e7651564e4d51392f35445a63364368694e434147597953636b5953524d634b654d4f6a49645868684847544a6d756779697a306f767a433970616d712b2b355562534a796945566a4232744746595536665079386a4d4132536d575552633446334668626a54696373716b35446c757362323366734f37647566577a6e796838382f5a303675376d5459434d323268364c41527a2f445963476f563759384d756d5557563532307171666b32696e696e506730536b5342426b785a5a7930584c72704453587766625862372f76642b396666666644787635696e47706c34776a495633556b4d306b714955455862656645367a756b6331414f31515a31514d3954766b485657743064426557652f525162396e73774c463635363545664f444f2f6e48373766642f696f334e51757942617034703673416a362f56484e3761526155794369704846325a42366c70645670754e73426d3075664e4b79684c4449727a707930682b497a736f6f70787332646a4171557a68456e426c523059356b544c2f416b56597942704f5673616a676842667944586875436356436f412f4c496f5a5255567057616b517a4141734a71646e63307754475856574150556e3255477537714373556773466b5672526a5331726132317161566c494267367333382f786e4b686759457631333956556c4c5733744957367539335a4f66632b394f66586e546c565272462b4c4b7a445a6f656945623947526c6f42674d704c514b7274732b7a56546970786441594f495376455261784446567450394e6364366f6d324e385062786d417a685161646b472f41524e494f6a4b373536676532786251715469753470694d597846566a526c47626c6e5a3562666363757439397746343742384d316a59306c4251584839717a52314851344d795a6d74723272753644683439457730466b7253706748714f7a72306452464a4c6e615a627a70715343305a57586c566d7953517551356d646769675463737474724e324b6f4a562b333569786f4f434b4548714e5242677538456d6f444f4232534969466a67364349766a504e2b735a47546464506e7a6f465142736957304e5459307047576d747a5933395046796a3576723137574a36664d486e4b6f634e486a48696970364e72494243345a4e55563455696b7671342b4d5267413444707033747a5a6c3136436f44784a6742544445455741332b6879774154494c744271386148576645316f4d515067536f4a6b5159307377436f36556a4a41384a424e67326c415750743767767167486a534b686f3449544b6449796249346e3964794f47617357443578317179582f765138794b7a6c7a4a6e4d724b7735382b5a3364485432744c647269744c6432317378596d52506232392f66352b46473931747a654645744c4f337536757241396f42634671537845677365767a555357696e495375494c517944626969456733383144556545774561304541485176693143575a5664626d636b474579457732496f484f6f64364238634c436b72652f754e31776e443747687532627039323258585839553630486e7935474544307747656a523566505833686f6b326274304a7966667a34436166484f336271564e376871716c74714b733576586e724e70566d566c78373761684643784d3875446f687a6c4169526167554f422b516e305a5a454a58736c50526242454549524a5563637741707375415147425a39434a7844573153682b616c764579425156412f3451634b416d71462b7a65574d637979576d6e72666e2f383862636d537758683833666f76515a2f614f376f4b79306163643847466738487730654d6e677233396757423438737a5a75546d352f6233646c696f654f33575553334d586a71343464754b6f4c6f6b55525a2b7062386a4d7a563337786565694c466f4132614a684334302b4a5a65734a6530654b426b597a3561474a3049442f4138536f52325541637149556d4b776f373272725a567a4f46352f3853386c6f306175764749566d4652344d48436d6f6236337633664d4a4244614a4639574f6d33713939352b2b394a466979747938334d79732f6276334d31547a4f323366492f69754b4c4377734d4844767a3646372b594e582b427a724650502f503073737457585837623931783565616f67694251455942796750325279344935784146522f5377524343326975474a436670714c376b7541595067637567533279494a752f49377365714133716c436b6336672b59526b6e312b427676765365656947336374624e6f3746694f34543534393733472b6762777165365531486c7a3567613665725a7632584c2b6b764e6d544a7478787a33335649386554564234576d483237484d587a447033667539415831747a63314e7448556c52697939594c7572716d5250484a444865334643484b7a4a46496c63363545315275354c6c62476c595537366d336e576d6561437279346b52625133316f69706e3565654f6e443446424f447a6574642f39766d7357584d6d7a4a692b3663737663334a7a616d704f2b564a54357930367037696b794f31326666584a78345371346759757350794565664e79382f4a4b4b7372544d7a4b6764336c5a5757576c70546e354263416477656e7337756d7572363864553131645556466566365a52536952416251446d4f7a6a4f5542526766334970337a6345396f653277794a423055475936425834417766414d54675068556c6b4164386942456a425a67474b575362485367517859653763525374574a436a367a54666548446c7164476c5a325954526f3530657a397a5a63374b7973304137636e4c7a79737372537172476c685956366249384f4e4466634f70594b42537147446d695a48526c646d482b6f554f48756a6f36447830344d4862732b476b7a5a3058446f63484149494466326c4d6e523561586276726b55796b5335526832376f6f4c5470302b6c5631636c465651384865394741594e5a37494a75677a78685351684830505948774b5077386d44742b6a7037477974717866446b61495235597a445556786376476e646c2b4241466931624374317770336f506264332b78702b6664314e736357464656645734334e466a6445554771774833523375394b53356e646c7236324f70716a4351316b70677966646f7a547a33464f666a4c4c376e3465702f6e35642f2f58757a703156556338416c6179517541366d38704b533267623053465a476948376238586e6b3367593357495777536d514643673652486a786c35792f665738313366374858666b35425757563553447870515546425155467763367530346450516167444649646b69525a743464496947644f6e7a3536374e426771432b314950656d4833792f596d4b31717575354f646e624e3230566f346c3543785a374d6a4d6d7a4a3735776c4e50476f5959474f7733705153645850514854705169775555675a356f30794c4f6a345967517643693634307258615a71446b454c5165466433563035656a68694e7676444d732b6566743979546c6b4a51784a333333582f375656645756592b644d586b6934584c55376432372f763333693131657653636774376676616d6d56336e3850756741684868436a772b6c6f62652b67614b71677347443868416e7a4c6c2b566d3533312b424f506d3770714d557a5668456d2f654f715a767a7a325748397a557967595170763436614138512b305a486f454f596a7754566c5853353873754c372f3346372b6955314d442f663150502f4f73496b722b46482f6e77663272583332746f61342b4d444149764338704b6b72453467435a6445307a6f4f385578564b55326455706b735158483735664e724b4d38666c4756565a75573763684d6a413465646f306a4d5454637a4e564d66625a6d67396e7a70694270336a4665415273483653496c6e324270304133552f344c504f6d7759694661686b426f6d73707843433941305177566f75434571564d67564532645073336c3936483131764144696934744c5355597a684a464d46632f4a3852372b68774a566572724e794a68776443646d43586f4770364953774d445a646e703165576c307544417473382b666550787831373937572b4f6274734b626f6468574e6d3050466e5a312f3767726d6c4c7a75734a52786950462b3149635861456c723634335037637645747576755768337a394b6558324b6271526b5a58746472683266662f375734332f34354f30336a327a663673544d71754a434c30556d2b767241645671784344676370325779716d70464935555a325a787565446d656f45684c5551727a3836644e6e7079566b556e534e4d3678575158353535797a6f43412f64394c3071644248354e774243554c4568757959494a4b707a746e544d423078744d5977644961686f5657676c7a7a5051776377565158545a416c4b305252412b4e465954496f6c444655443178454b6837642f7461472f6f355056545139474f4542796d4d554249414c38707171435a544b36526b6953486f335171754b456543596d546838387347484e6d73374f547151764a506e686d6f3837756e766d4c7a752f65766163714b4c4b79746e4f74636c6753533733776b73754854472b6575753237623044673941587941634f37743237613950476a766f3653704546414479526b42475034564b434e58515852614b6259644664466a71707972537334484852694b4564365435383830306c6b64426b57597a4667344d4253557841664a453078654e326f7078476b544664707967494147422f5941496f4d4350502f3438382f502b55686964434e4e454649715442464a4a7a4a6a674f6d644470453863546b57676f46415266623544344c332f3571346f5249795a4e6e41674f397045662f576a7a2b76574e4e5455756a48526247436e4c7743435147617472416d61364b544c4e775765346e4844674164776d4a6e6f613674303466746e795a514c484a554a6854564833487a726345777737307a49652f4e4f6671365a4d633367385132305a4c726c39766e4d7676486a796563744d6c6a7656654f626a5439664b6b714b4b55766d5930526b755236537238387a526f774a6f70326e36575162613571464a55705a494b554849496a54625265417544432f335a5970396732647154722f2b346f7562746d78326572304c7a7a6d4870356e4e5737636f6b446354654d50706d7036757a72597a445a6a445957394d673677516a64375a3767762b444c586d4c476734496952694645343575794b78666a517077334953476172765551426b5a6d5a666663656461392f374a42694d3950634f664f2f75752b2b36393336664f2b326a337a366c4857764f31356b737a6846547856346e6270414d687248653145794a7045575748624373326e4377525a55485761705a6c515a6f7367633357784b523539392b4b793471444f734939345762546a5957466c5845676c46543155644f6d654a77754a496a2f556b655147364f456e36376f4555464f4b5a41716b656a313645784164437a72786b476236457762766555525173484f3773637647764b7a486d37747536533467724e436f64323732754b68486f4a6f774f717953755355744e37616161486f706f55536647355462385830672b433579524e55796972567578316345774f786c52697a71392b39637a324e3164586a42723373312f2b6b6e55342b766f67615277347565766b7443586e44364a425a597a51434a376763496f3233577959316d6b486938757933614b7a6f6d45685572533942345732396742336a6c4f6b535441576165446b794b717832526b35757a375a444f6c67626d357552705876314e3444787a5a734f72783946326353636a684f6378546c646f5173586541356e474461413048533754415a30702b526c756a724e6c334f31504b79576563766f7a6e656b5a48717a6334684d5a4a3375343863504c52372b36364c6c6c39516d4a6e6c34726c6a323365732b65423949686a6b76775547344f2b336f554879414b566758304d652b415330395a74634572346143417738387642507633662f6779366e6130524a4b57466158337a3632616852493659765844687137456735466b6f45496f4f745052714a31353038325333474242383443464b4a78565256376b2f45454a5978394c4155382f6838737177716f526a4a4f6e61762b3072556a4a49706b38654f47326378394a456a783064586a706b386331596748734963416d45537067377044616750696462365136765179396e5373427970665a4d7559444f653565784d6a495445676d4b6f45614e487057656a57626e6d55366459793149446736383938666a327237344572302f7a504d627a4a7363507972497650392f7965325558482b656f6b51766e543136352f4a784c4c6f775257504745385266656565663853793864505764325365576f54483971515656564c42622f394d505668773863724b34653732546f727071544c2f37786957426e6836374b53454c4141545336674570794576552f696d326a512b58726d51456f535277504c3544594e52342f2f746d62622f51304e6270647a744b43676a5566664c42317932614f3551724b79724d4b696a494b69326164742b53386d32343839377072584e6c5a2f754c43325263737231363274474c474e4e6b6c69413557393768305868445252496b415151576a3655673476507174747a35362b53555059475a563262647432375235633064576a526c62505136594a737379476d4e446d35596758494d4f414257664e51314c684c7242456151555433676444676f6e4b59496347427a772b4c78704f566d43337a5033334555394a302b4976543255797a33593257455a576e745064316a58324f7a735256646439667a486e353133782f666a716437692b624e2b38744b6672373776376b76752b463770334e6d332f2f7a6e747a7a306b43737446656546643935392f3063505058796f7268454d7437696f614552467865694b3074484642547457762f2b4868783651757a7454634a434b67536235374135414161644b472f39524b4150644f6333616434636e623935454c6a63705256742b59416d30616553797a4d46315877443062646d35343645662f79672f49783053553962746876697735744e3133372f7652784844484f7a707961386f2f2f486a6a3432654e326675466173752f2b455062762f7472332f79346776706b79664a47526d2f2f5772443355382b4e585846696c355637346e48676a4849334f6c6f54772f444d4e4857316c424c633847495574376e79737a4c416573444f4d4e514e45524b306a425a6a4f417035757a7a657144686a4d35676b6756782f2f4d76506c303666333744336f505267554844744262656569307538414455437a4a7a4a6b2b706c7350686e39397875344e6d424d457859644b6b6c71374f3556646465643431313149634f79416d556c4c5471365a4d47546c684175587a444962436b4f726c6c70545141504b394b6347653372646566315053394868436e4431334c6d3561715637503467554c336e7a6d365a3166727064436755795057776f474943314c2b73736b4a4944586237414265725750514654666641374353316f74464a416676424b5746657a7239377264413331394a302b6338504463697373754c527456795a69575a4268666276677146416a586e3635627547494679334f694b4f595746415a4359595958584636664c7a4f4c345953732f494b525936703857646b6c56654d6154703153565330764c7938616a59426e69765632563432715848484a4a6136304c4d764e57535457316e526d2b357366676b706c35755a4d586a6a2f614e337043524d6e383777446f382f574549656c4254544a4f68323659516943774e494d65465366313575495269453269496f635363533366667a78582f2f796c34366d4d366f6954356b31592b6f353879664d6d6a5636316979303461444c6b31632b5973363553334e4c797979474d3352723936343961396575652b2f4e643174624f6b7a4e616d31717938764b6d7a5270616d744c477741494147397567562f7a31687637743234324531464952654c392f54364f6833346a4c32714c616b684f706b5869364d3546433046324e4667446659507641626b442b454d34336d37374e30526a654c624c546175716b38434d574f546a64393571726a7674346c6751774d6c6a78303364764f536953356f626d794c396734716f374e7178612f2f2b67783938384e4742413464557a5a514e724b4a71334d4a6c4b324b716270413035585363662b4f4e6552586c6378597648442b68576c506c505675337248376a6a5a6f3965304f7869474c6f7571474851694761704444546376494332744b454a466d4f782f357474346953474d577a4f4575446574494d413845443348706759434152697a55304e507a346f51666666505756513376336546784f53416c485470343036647a46397a7a3261465a527355355155566c393861585844753439384e787648314d54796b427a652f336845336b706d576f3473572f54446c4d79586e333668555654353836664d567467474530554239706131377a38347462505071595545664951336a4a526d4e48522b4c5564314c35326a326a477a3653674d51354278657a64666a6a616f6767447430694f5958684f4257577866772b5546443367463971776145336e44494f53524757673739316e6e7637383964654d574c53316f54484c6e33722b6f69565a446b2f4473564f782f744448623731666c4a6d6e52385444322f635347723531376362502f726f6d3042393638706e6e4a4e4d69484d35524579662b374f6d6e7a726e30346f6c7a5a6963674f78484676647533502f57487833372b30494f39765432524b50794c674a3752424141345a3743766a7745446441686e503041424e437752416777565745394771733479764e4d4a49566f565a514d6e6e423576536d72616f6b586e4f744c54434c644c70716b45627356556d584135502f337777343266664349466774752f57492f4a696f2f684b64586f50485a6934786466646a6133584862314e65664f6e782f7037746e2b305270492f7976476a5373704b33766b6c373863714b39372b754766484e2b7a6b37634d7874516f744451434a4963442b763262645365325447694f5361685366797873386e514d4d344b71464e496b6779466a7574776643626c5376456e2f435765686e364f5463524e486d7a5641585a5270736942334b6246767735655033582f2f7367587a7237726b5573626c765061717937642f735862762b6e575a666c39525475366375664f4f376a3141364e61684c54737753534d4e37505452592b4243517a3039447a2f77514638344a474a595a322b335168443938626a4a737337553143747575736e706371616e704c63304e42466f4f7a37444976432b775547587a34506d7a662f4f4d77794c68694e4374457950496e4b4b43694f533648533767533045546e53317442456d6349395a664d374332783938634d47464b31305a47544664557741377145726c6d4e47624e6d343865766a49756a55667a3534307057726332456d544a6e36382b73506d757472717169704c553074486a496847773539382f424638355574507755326a382b544a563539394a747a64705552436c4134354742494238706334324262436d454f7473516b6b6f75686f615248424d7770684752796c73784261425a5845444971676e6678674a4a795558354c41494b4147564139345762535531414970366c4a4369385536366b362f2f2b797a336132746d434b506d6a557446413573327277684b7a76446d654962555649795a644b6b545a392f3064765656564578496a4d724a7a386a363954686f34663337712b7672334f356e427a5075544b7a61493937394b524a6c31782f2f514d2f2f336c78666745464b6279753739792b6e535a4a6752633850762f70686e70666967384335504173364f396f4f485641506d2b516546355a456541517239634e7248507776427850784d4c526654743241423470485466756f6c74766d58482b2b586b6a522f7279636f483378534e48474c4b79666631364a52775a5656414d376934314c65585930634d6448613056565a553454664370486c3947536d642f31336b584c694d3438765442412b382f3833526659774e6e7149797534624945695173795152795a6f4962544e757548434153446249756851466f424b5934354f59556c776f594d42794a6878677a565a4368493843486642796c43574952366247736d644a793270596947535542462f44534a78384b437164667432377635722b2b30314a3169484c54443777676d517150476a3845774c54732f753670364c4f675a68466d66333066513144575858745a575637397236395a7856574f645049387a6a4b386750373234364b5a3737316c793156575a3552556231337a5356467576694c495569384e5648494b6a49433850776f303350525634694f366f504773616a676831456a4e70716d4c4d364d374f646d39714b7154473457436f76375574334e577a35735056436b56626b4d5a79334657333366723453793943566b51356e535448545a733471626e6d64474671716a637a43324c4332466c545844376e714f725235654d7146536c4330465a756555485674416e466f38766666763076727a2f2b6579394a574c456f794938476b4b4e49424a7278737777633177684b4a57673058326937524343514832694a724b6c67676f35556233636b4d472f3530702f38397065653749796f6f51436d6a3273793765445247734f7648536c30473051493965686f53795034414f31656f6b526a4757424b494e3534724f33773456392f2f2f622b76745a37483335673349774a343664586b79354f77665778307959317470355a6365454635574d714962475a4e484e5730366c545462576e62376e75576f786a435a615a4f6e584b4831392f725844735749786c4c55466f62476f36647568774968774f3967384b484a2b576b564538616c526265797667577830346162662f4c476b344967544d78324a59515570614e4244516e46794d4d476d50732b4e3059365233384c7072727338764c394949516a507875362b2b65644e3761794b5269495132507a425430394e41302b2f34775232576a375a6f55306c45496f6d6f4c797554645472706c42524953795a4e6d6e546648586575662f767472572b2b526366566a74726d677651384a613453466b3351764f30386b636941313552703250766b715961394851396164456f794a4f65574d545a714d44666639374e6c4e3935574d7666632b78393765744b435a584744646675794969454a726f716a4455674e525a554d484b43565356726f72686651427167634c4a4c6d3364473449735a5673466b746b6e4361784330585846692f372b434e5631326643497557624c43733448593651662f364937327947624d41584c48346559755738446964577a70434a79775a303372372b70372b79634e6231363654634632306c42767676572f6d784a6e644e53335a74437359443063354b2b486a574a666735707a324d736876585076776154676942416641347067626f794b44515a33476651585a6355774c642f53714d626c695a43575237744570416b42356765437633626b666f4a694d6179706a4a674a426c69434f48446c6f4f4f4779526d746e47304554782b7472577a6f36774c735a75734553314d3750763969782b694f2f4a48454a33554d36395a6a4b55674b4f376b6f44733050784432524957685a746d626f71416663706348306b576b4268594754437742337075557375765872613067754639454c636d63706b463632343974624a63382f56306359715868777456344f664577784c365a696d477a4b4a6f593033624f634d556d4e554378494e6a71596470454677466b574c53687047665037474f3865323773724e79435630417465734d77304e444563664f6e47777661665a7743574678514f392f5a7846444c6132693553704d6e676b466a6d2b625a65625a48534165514b6455566c656b46456739345946555165754f664e5341307130636e7756413136595943696348754c70576442775241697543484144526445446751424f456c586a783471794841674765727336307a4d7a4f4a4b455a494b4d7177633262323836666a72524d2b44465755374461673865646a44735a78393868437536484935324e4a77704c782b70424b4b42356e5a4b30754d64506538382b665148723778436f783135565174747834774b79416d69474e7036455a586b35736e6f686765416b527a46676c3043434a51594d6b795a58473736346c555858666139577a795a6d576764473030442b436b664e2b376947363664666346354d5261504d726849457949454159626a534a5a4547314a5a71454c3766676f536263364d52736a6869756a536849465a756f656d4f786f61506e336a6a53396565566d4b787a564e372b6e734c6938736c654e79533032444742624e574c793973596e4479633272313642392f777738314e346436786e6f72576e676f6a4972365453616c3854627a707868475261714c69677342444f6475324142384a433248374677396a537374544e6f4430744142465a4458613258462f79706163663237494f63444c677a652b6b536a4549376f422f64764b4e2b372b474b736c4c4b7752586b3578376176626674364d6c7a4669786f615738767252725a30643333327175763366767a58365149376a522f4f684e4e505076494c35755048324d4d6e644256744a305375445a6b4d324267795a6b47464d6a514268526f64424556477431585a644b434932615a45637a4b71436939356145484b7164504a52304955344150414c506d5752376372754155536b65575a78626b484474354c43364c484d6461716d6b704f71526f61454441316d4b3732494553716b616a4142416630664d73444656694b565a54744f4e486a7975526147465a6853524b437865664f7a4177324e6e574d572f2b77732f57664f7a486d556b544a327a597548487967746d52766f4839473763756d445239302f6f7663796f717376494c4a564672713633662f766e6e556a68456b4e693432544e616d7335557a356e442b31494d734830534f6a544531574854634b7a51516a756d5743437a435a4d6d785755704b792b585a4147546d34472b766c68766e7955727762624f5577634f72627a6b6f6f7a437772626d466b7a5774332b31716278362f4e687a35727454664e33745853655048586637556946626d6c6f396859374558763364487762724739305735694a495335465a6c71495959434579694f5463455567524c4161554a676b6d676444534534754d53597268344d736d565639363536335a453864534b563664776b463846454d7a444f69446a6c62484d43535a35682b31595061694b792f4c72786f64683268496b68514a6f5144366a6753574c4568466b4b4c59686f6762634855434e7830456855755367474565696a71775a6376714631393036455a4f61766f356338386854654c452f6b50624e32314f796338654e332b7534484532313952324e3755654f584234387371562f7053302b694d6e535053594f364b3370626d76707a7351444a615048456e515446387778504543396332746657644e77784568346742463477525a564636754737724836355941392b4f596b6b676332376550314c544f756f597a6a51304c5679776250626c61303754366d744d67794c785246554a655674475945596350487179707161305958515773617a7079394b7658336772556e794843455243686d364c514e704f6d7151464f5154665a416b4f48376e52414263464a39416473452b337752484e78336171594d6e6e35446464577a702b745155624945417145595241794244674d725537525445504354666851642f4a7a4c727477385a577233486b354362517168415a3369656f424b374456777134666d5473554e46674830566c54425a78794568526e4747364349435470794f59746e377a2b526d77774f4772456142666e57766670326c67306e46716137796a4b72707738377654786b77326e617a474345464a547973614e6257706f784f4969513546314a343548773247417568566a783545555935496b36334c684f4f4c69454550506a6f5a6c68654451534e496971597a38664a6e4144746565476a7435416e42446a73644f487a67414b47762f38534f59567a437a7653506d544b4b397269656565536f5943592b634d594832636f757576334c506e6a316c4259573333486a5470792b382b50716a6a2f6164616251693456515349705773783051576f39475767654230624c37614c2f5a514973415a6b6f6d714f755a77796a536a634879666f73362f354a4962662f7a6a79726d7a546336684d37784f306754446736596a43774f4a4541544e6351544c716341756c35644f535a313037726b2f6566707058306c7067755759394853465a5557636b4e4474446153714766616471634151634731495636414e61467461634b6971676373717179696b474f397071482f346c7074626d3575584c4c386745517144317867785a54546c49686665634d5847625a7333624e6c534d616d61536e574f58446a4c64446e32374e736e393354324e70334256505267697079526c5a33686347354a475355344a4257534c334264517977394778704f4c4552334e4350647453513548757a724f3333382b4b584c562b7a61764258364855764571795a50487577505a42626b5663366169724e307048396730377231442f3330702f6d567052444b6149597179533271476a467930337676663746364e6139724c476168726558414e647636442b70687a2f656876412b455a346372794c33426e6a42524e796d484f366f5a63644d695063344c7237316d3266647534644e534e4d79434e4d5943755750415570537245312b7a426953434674776a61304e623849462f4651546e6c476b7a42767636616872724a555552484536536f42524a646a71634a6d51323649653259305864524d3959732b4d7647686143617578467170596b5353663237382f7765532b353866727938754b4d38694c44684c6a4c4e68772b416537396773737554537375384b656e6877594358706637324e366470773865736e526434506c6c7179357437476962733267783433594270494a72364371413675465930626470574f64446632786670526c6d536c5a6d5042484c714367445277462b51597045513633744d2b664d6e6a5237686b356143554e7875567755686863554647456b6f56734751394d6a38677050624e2b785a384e58744b5a59756f49654d4148784331416d556e38534c5841304742794e506957684268796767703735517a49715363564d793164517550437979365a6365414877776742337966437172714f39396448386d35337a32345355414a324d6273574762354679514b456f543137756f717576576e6a7070557871576b6a5634345a6c554b79736735692b75567a53467447306f346b574e6f42794a4a4d5a677a5a31584a554775397133725674627333746e6557342b43663043393874415a6b703742476436526f614f6d7a4b46543567786f367934705048344d564f5243644d734b536c706157375244544d744c786670426c67417575586a6d38594f6e34596c5168505142494c6554712b33704c79735a4f5349614452534f616f534e773078484e36316471324434624f4b697a58374959324e4a32707942472f6a31743171516a496b4e645162654f50683332312f357a326a727a63565465776f4747306b4d466d695459306b414b4f425456494754356951584b413979394867705432507132495536664a5a4c6f38734f4b2b363539346c4e364264617a47584536645a694374653173566842414e493154626849656d686d57454d506f47384572356c636254524f38454a63465a75395a694c3737787430704b6c34417056547241456c34496538674970774e42316f63424646594c58634c53704f50674342485a4d6c594f576d59714c775874614776373637445074757738716f5441483874414d72577441365133733337594c695a736b3033507a346e32446e58576e4161424252467831396457486a68354c7963774357345a6f714b4337694444367243634c6759596a516c42586538324142574750647a71724a3039363963392f6d6a68725a6e5a47426f43636d754d6e7847414948463867304a2b49525074624f36615071573438644a78577a653736706f647575615072524433614f34444142516f3344445559437a4a75586b573353674e3651616b616a766749727a5a49524b3455644261696d68425856594a332f4f48466c796f6d547441355673534d4743543439674d504e456b466c704d47756e73574f596d7652516a4838416c3844743969614f38304370796e5a426c777573377a312f3777683966636667667639556b47326a385953522b7350336c646c4d4b6749527649626c41436957776266526f4f446e6f63764d43693053456a45582f7654792b392b74527a2f52336465694469786d677678523361755565564a454d7a4341304c39513749696269754b466b5a476137633346676f56467861716971715a70715156715074676638564e4b785a653931325743536d5162704e3445364f662b2b647679355a7644514532564a724b366272484f38734831334a4f76673148362b786f764c4b4652654e4744752b756562554a322b383358626956416f4f2f742b6953544963446e4d437047376f495336415055427959484d34526f477a4d776b5a556e4e5655334753517673493055774d4a36706d7a377a673271744c4a302f416e4b774a466b7a544f675246676b433759304b534131344a78564b7743447432495663466262566a717630483371455169585970417145544f4d4236334d77704c4572317033523364556b4a4352514b7667483555765a7a687979774f6f78444152704f52526a564e44435459566e6f7553796a683131412f7948754e6e5630684c7236536a4d4c4b7372472b504e7954725130466f38666e656e7a78357337336e72714b53306568485a577a35774f3649627943474f6d5432553948735741544165677378326c53576a6457644677724244596751625a545a776d47597a6d3262534d61526573714f337647546c31457342317a724161442b37744f3347635659316a5234384a78626e654d535043676444323539385a3348613478474953566b77314c465846574e706c7167526c737052426b776179504968566b414e71364b2b73613145414d517070535177566f636d307174454c727274797a4a4b35756f63554859594231674a79523038617341307647565351354778423652616d474f6970304d6d334e73466e774452494e64417042696268566c796769437a76324f554c6c3931784535365849664b4d496243537164475953656b716a78365741657141636867644a3947594f4d6e71424b73624a4776786c4179645a79524c54526c5575746276332f62382b3836736e4b777031593669334f50486a744c78654e664a773632317833444e3947566e6a4a6f3939655633587971644d35464a645947574369794c567642424650325077443138476c5973684f742b36394941354b36343671725478343435764e34526f797031484f746f6164367866683149616557382b53766d7a572f59762f6376547a3152662f6f6b7a35486f7952504a52334d6976496e2b4934364377674f77743351514878516356796d475952317543534f436869454c584d6249696e73652f333178315a68674f4d775156434959517076394542694874675a4771527959726b70674f6f4f624c473678594377454d4e6e69534c536842574671754b6c436b6f41655959486d71426753666735787a2b787462754549697548596166506d2f6569337632477a4d384934466948784243426768307444554268715258743432573144392b586249777a496f47326b6a466d36366e53673534527532766a4653342f2b52753376766632714b365865586979654f4c78746d386368794b59424959627a654369574c53347051636e6e3337487672476c596a6852455944636a656275305a5267676c783166626351316664724d5751643337535a317262577462664635532f77702f692f65582f334a572b38514364485055706f69456f53426e6b65474843624b4a4f7a6b48546d2b72777571454c3442467866584e497833434c6b357338342f2f395a66504d4c34765a4479737a77484963744a637a51464b677867587450737866396f70517a6f4272707431354a4d2b2f3548456b7748697231364772364432714768674f4a31744b4d4e384a37537a52535048314e316c4851534a4f2f31566f775a70536a795944436f53434c597377627844426c337368706b7a6c2f7a486c3653714258674c527172413175436e726231644e55303146716d6674486c6c333379346b76374e6d3547443374696d5a565858375876384d465631317a6a536b2f44534272384d44514b4c62684968734a684764473336563867516c42754d52364870765730746c574d48466c372f4c6a5933322b614f6b7669422f62744f376c7658324a7741426446544249356c744a5246674552414931516f7a715334793832556f44336476356d367a6e4c6d437a4c70365a4e7565434375526464594845637a6a4555445445557778514e56335654535a676165706f5a4451445033734558506677587241617a5150464e457649494e46614759673159486a68645457567379364d4d4856644555785a785557555a6c35365153496970554331464f4c7965334a4c696e703665574169734555343253517645417745534b6b614e684e36697a3146422b53496b4d62716134476845673446423375564979496d426e6d3634784b6d6475794f392f615a68544474334d656b5132727137356c2b77777149706e474a517031482b387a576474516768664365563458394341444151797a4564705464496a675064335a6b70366538383835794c34625659664f66727237494d336444616e4a475a79564b3047496d6d4f46324d6161714b78494435304b536b4d78426c634f512f5656764830655a5a7955645a77437441794b684a34693750315866664e66335343794f61796e6f39774574636c67574362443979584174477055532f59536f3079314773494c67396e734a696a6d5a707478746a57516e7141717744756741354853515630456c4655514b4257434b713950664641674f6d72757161624b6d5570364936506456502b46324555346868344a7356786a416851336a685a37383475574d586d59693644546e7050354736496963346846704e44504958554275544d684e51475535514a4d4e454655556a53643774436f5243446f67444c4b6353784c3176764c483633626654432f4b7575504e376b71347a6e4944757449443842396949315058664a554c64566b51514957466e714161454373735535623757396a2f392f672f33332f5844442f2f342b4b6b6a683557456d4a655a45513246375075544454514943646443574d4c55434364494545534948736545314e784b79434c74634e413833782b4f6b43786650486253526466645544702f6a67364a42304e48564d56554e5339466334703234347156576e632f6963735567555a5463494a6d6549632f50544f7473486a4b2f4156544679303061516f6947415254513553417466487572734e62746837627537663354494d596a6368697a4a356842486c776b6b4c642b504244303563766a64456b3457516c335843435a315256637a433836375050313737316874626677524b346736486c574a536e49494343357149434b534f49454e3274627959674251526e6257385567614d64557730727636696f72616548647a726d4c466b366574473575343463584c48714d6e64754671516147456c426e455569744f57486e4d355a49394a684f564c55576954436f64694631696c547071617a48472f6f2b73446759473547616e747247396f69455a41363542675142534652517531467a704a434e324251634167564142434165674448386936586a4f4678794c30467835523543785a6574717067516a5874636969516642494166576c49386a7471616a352f2b35326133587539474d356242676357592b4973324943737938466f64327437572b4f5a35747261395052306c794259454f546969623372762f72796e623865334c69357537594f6a38516f5265464d457a77415a5a6f3057494d4a376c63504a2b4c46493871527932585141387242445473637a745373724d4b43764d3732316c676941576b3478334347437267477856586f42646869737630554b444367486567714d4d4f793743332b77456d4c45415679536b735858584c785732752f6d44686e546b46464f52672b4a4650326d6c5934455a6b7a31494c346c3854535a3048444569486965314b4c374866496b4333304e42625463766e394836315a4d3233364649626a476b2f586b676b4a386a63444a626f413656444c49534f6a544e494548476c4847796a496f5a4b6b597545364c3067456e544f69387571373738306458616d54474f3130494534687a345565496e686979395a746e337a6967544e6955514741705745784268496861792b2f52334f44736e7a36794a46515631644266703748347a6d79667631374c377a515631737661446f6554546774444a77353271495a636443654537517356754236656e747963334a6350682b7746396b4941634552584b56564e484b6b322b303964767945426d6b454361594c50685370344641347443554276394d677962656e7163413841533144445643427a44457a6c79326830394b366f2f453569786544354d4462617841347741532f455347713564386d516a5230624573524f584d454977676945552b41502f48372f52414a32674e393838395a38506e486e776f61657543554247365149565630437767612b32424d47735650653667636d67386e4b78616d3031792f616f3663505033424a35345763764e306e735135326f54344a457267704767444f2f4c5678734e66664b345044484361516d6b695361476431784575534159386141643441455679386d7876643773594844416a6762646565776d58525537585977503932536c2b434d5551303642424f6f6c724942473044452f332b54786950444859307a742b376a6e6f77516d415156555a67336a4e4d785a4a35355a566a42343371656c4d633239506e366b5a36466b4f714e69454a496c6d5478514b70496a71684f37516f4b4130787a70644a544f6e6a3139307a757566666e4c31726263355555624269496f437167454351326159464636794576547572476a5949687736416b6c436f38414d4e594238454d425674614a69784b62643237713765733439642b6d4a727a5944714143634163454a596a7361367a644a47694949576c4742524167316741674e676e4b6d70712f363368307272373852392f686c33454c5070514e394275656d614d334854725163506e7234713431364d456a496f686f4c512f7148724261686378734349566141504846777a346f6d5552776c4b6f6d4547473038557939516c4b556f4c703550784b4a675365414a494c39545355673834527854415032436b79674758456a54795650785945694848377464674b5530544263564c5334714b576e5a5936764759716f36324e464a614f6a3561736c6d4138484a41476953747a434349594a6c6f36646f55335255564b3538354b65375470394979632b74486a755a357342665145505272646b6f7737486c6c32777a7167523535724f69737a722f363661415270765164424d38486f5057643438594f36366a7532646b31646979555a555579796d47595246447a683936445264466542624250415479444a7a67336536463535302f666647357a7252556e49614d412b32744a7873712f4d685131663037642b7a66756933533159334c436f666a484c4142304472437732684645686730386d4d3447697656645258534d67617948464d334e426b51492b516238434830456d41772f417a464c5454366732765142496f5178626744505a674a34797a72774a6174583637352b4f544267356147666739674261336b64336b496d6b67744b4668353758566a4a6b346d4f5237425a6a422b684b5652384150486d4f775853687674782f334c686e487538755544666632392f514f7a46793455334537774643524a73547750415164302f56394f77374a433348614a64674658427670484557697041303268527869427570576b464b746864642b752f544f576e484f38705436754b7a7a446b416d523051464b5146797847464d3074495243576d47664b3554694f762b2b75786263656a336d642b45387962416b6939674c4352544657455334742f76416c67324d71516261576a49395073447730623459597a684e593267674848695a4e43774a4f45716a4a6349674c772f6e39764c7561462f4955677961596944416f5a557730484237486f4d314c45477a484f43374e5145335358442b4a675a6751395659773558716d5468336c674b796f54694f704152514f5442356e71445350524f574c36345a36476f4f394a49434c665a3370516d4d49635853636e4d53345142705159496a4d79356e414c50634a6158582f2b7a6e72377a31305a7a706938614e7134624f6f44534b416756444f38524473702b632f4c4a524462796372516b432f5175712b4d38454b6a2f76764958314c57646f6e6c323666446c596f51623268683468414d78455353324554593056644a61764746393939343866576e4c5278665a4d725832796e6163674e777375423863564764777165765835664f6759574144736f43444c7032326a2f69636c6166746665344368342b52627341676337662b6978324b512b495179307a4d59686f4641674773617a3348415874314557366168732b7a5767503364654d6633623776376e6f4734794b576b5378516a343052375778764e6f47454b703873546a53654b79797475767633327439352b632f71383256506e545465317238646e76307636546b534933427244664f2b7537322f62733466322b786373505539534e514d6a4644534a345543756c7864456d686b396665617157322b726e4478466c475237396a4d70512b4175346c3353365354696358426238556a554b546855434c6363416e33326d4268712b74385845452f794e566d2b4f6637327764632f672b74414d714f6f614b387653503142666d684542313055365135386a3351496453564a34436f527168773362635a39447a3869354f53464449763170784c6f2b667151446d6f51355630704b5a506d7a5174625a766667774c523563384366344179367a6e644e33386b31774d4552444a4666584f444a796d6a72364a6837336e6d434c34566b4f634870696b504f42497a6a684d777859362b2b2f344738555657557738554b547442784d46456b58574169326c304b66424f774477656743335951446f555a696a4a305345414270714b5a5a424e74762f55667467566c5345682f57354b66662f76626233344d424b6d71724b6b674b726963447659486268614f43625352473379434d435a43484e416764424b6172344377356e53506e58664f30687475637065554a556761556c394e4e77573357394b4e73564f6d706d5a6d62742b3635667276332b6e774f45462b5549764e6a2b2b5776684d52456979755768726c59706465644946476b6e74506e487a673137396850463430394d55776b4b32587a5a7a35677a38387761566c6d68524e4d47784d566f624f524361496e737071416d4178415066695969774f486a5957444350495a4f69534c4d566b4554324748444c2b62776b47436d497a714d4133422f597864472f6f3232382b2b667248614e63706e6b5537504e762f4c4e3267775a6e72426c77493562683255354969744b574978726c6a736a71596b436d766238624363362b37397a342b4d7850434d436b496f6f57566a42367a36676433316253315a5a6155654e4e54646651775767314639652b6576704e72414c667435364870727454552b6375574459624333624a792f6857582b334e795641493367454d6b4751734d6f70742b63514b3032416c6f7a51414a496663496635505a426b524e553963686151507a544d52694a5041586d61594272673959543745306b724d4a5342685668776132304676307948463772417564446d3842334b6a32417a36536f6b417a466f4272304673414c43546b326f4130494d357071676f6e43537748426d364256345476556642444a38462f31434d51725957424d302f312b5545545642774c782b4e6f436f4d6b524d7a4b4b5332392f5074337676446953393630394a5658584f48772b30464e6f4c3351415076733735612b4578486134793167585177635a65546b4c44722f2f4e5566664a4258566a356c336c77644541524648446830384d7431582b6936427639594245776778554138426f69576c415177476e776d627071614a4d457274424c414c6b415933754667425636473077445a776b634d4456566f6873454c504141514d467a6446696f422b595139344d42794844684871424d6b67555a5949445746396947666a615a4c4a453268375275563059674d4a4f5567585633486442764651423941637661397757676b79557843634454766f5970536f4b646e78375a7450583239436d37354d6a4f6e7a5a736e6f3755687a50697030326965687838424e67636c7471486264303744532b332f47526b796d6b4b7952394d677176737a7379694733627831367757724c717476714f384c44476936556c397a4b7350747a69387578677954596c6c67484f4977576f5342397658416250674b6d584444766e3339725731474c4a3775636750585531505430724f79574b66543558616d41346a4d7a684a63547244616344796d476a726e644a414d4c61734b78544b73307a45514369526b6b58634967447756545157527539477532666d5a4f546c4f6a31767765724b4c6976312b48387377344a5a42346441446f7a4638306f775a704d385056676d4f462b55734a435143594a4a6f624275742b785154494e7a663358505871514e3764566c4d7a633563664e6b6c6f32664f75506e37332f2f4a482f2b595731494b6d677453522b6b75796e666736447358343363695174514277414c677258413072775a2b4b5373337436656e653850366466662b2b50375731755a496430657177422f637479387a497a4d6e4b346467474d67566b426e5a36523446504d584149445161732b723348787873623366536a4174734258494d565156414e42674a4b366f45356f7275486f492b4d4c544437664b6e706b436b444d6569444d2b355052374f4b535155575a516c7341695735386f724b73416c4f46784f67426a6861415441625152794642304e3349496234486c655557545737515a73553146564a57536b517763676251654844373848657951683239524e53354b4d655052586439375a66757159457a4a4b334c7238657a6537632f50652b7643446e7a7a3661467075486c7255424d6f4c55476849666b67506b7a7a3537756937735549545054515a38435261555162795243766572497a4d444657524e6d2f6574487a354d6d326772374f7533754e3048443536484c4b386f754a694141566764496146734b4142765564544d675345754a5a6a78305064505a536d787759436d71704a736879585a4248425350423179464b675150674557514c4c6e573458654e74344967457963336a6337643164384459745064337239346d534350594e636f456671376f4f767763584b594a44566c556f6d7161685a2f74415347625a2f504a7962333665695234316a4877702f426267447a5147552f5667613875584833323435624e50306a6a4b787a464c6c79387248446475382b376431544e6e566f776567304d6f52534a48735a6843417253444d7071342f47344a58657066542b42776f4143684941497546593871636d706d78734c7a6c6f71476471617a62646238755a576c526247654c6955772b50453762783363756c574c524546374958474841494c574b5945694577545943614154744457366f6e49735741737443454a4b616b706d566c5a57626b3536547062623738504153526f3641457554774157334b794d6e4f79556a44557a5a646d5234566c364f792b666d6e51344e7771706c6971704d304251364e79734c32754e5053556e50534865355841784e702f6a396b5841454c69636d346941354b48414b59474b4152534234514b70695948444e6d323938395072726d53364843374f6d6a523837612f366344395a2b556a6c682f4c7a4669316d5855775958677651576851505564354466762b6a476c2f2b61766873724a4344685251574e76594572675643694b4149344b384f61506d2f42577839395376443870626665766d48484c6a55527033533138664468444a374c797331486549486d64424d7a4b4d5045445962436a2b3363452b6e716a2f65483035302b5541644a4641634367774f686758416f6b6b6949397649576b75636458702b66686f6a4b38693658322b5031352b626d67543865503635615533574877775849332b6e304941784455724b6944515a4476594f4467634241504271304a49557863514541726b5747596a463369742b563469736358796c44376b7151695a447149686c536c4c547537716676766276753046354d6c364f71764f6a61713863734f2f2f6c4c395a50574c6873786f4b4646676e577a6b4b697735496b4456644277524d77454732766c4545683954756c37306145746a4c61662b7877674747534a44454d4178704e3038794979737161513464506e7a35392b353366373235716959624455694a52563163666a6b597a4d724d634b616d67392f594b4a6e444531753731473843444b614955446f6456434938455a6f4235636a5234504a4f684d5a597861424967666b4c54347171697772635578626c644f52566c7673774d30755074374f6b574e583077486f58454d794b4c4b6a68476b7441496c417a674e41524a2b4539442f714559526a69526f4c31657a75394e6d5071344f54504250344d4e4d6867443258767230534f7650666e4870706f5475714c5148482f2b7852654e6d54392f3836376436626e357979363646506f48716745674441316d552b693254796a6f5a59674a337a6c394e794c3854775464517a6b5a6a696353695a5155634856706453644f514a644c43347656684e6a57327134426f384f52514468634f624b534652776f6a31665141784533725630586a3858446b516a6a34424f474267355a786b7a613657425366487836716a737a7a5a65643563334f3875566b5a525958707057564769532b2b2b69522b7261573038314e7832745078335374614f79597a504a53543171716b4a72695445396c764237534a52414f4161536a61466f556f717468517171444358774d66445a4e6153513566663538594439686f4e55434e667632662f5868683756486a736a786d4d666e487a647034704972726e727667772f54632f4e5758485935756c4d4755686557525861584e4c2f2f466246396d39445930744468643061676f644139414f35443738455545704b7071412f6463382f4b32624d724367746665766135727061572f6d44516e5a49796365614d472b2b2b6d2f576d59453458634f58574b792b5052534a5656574e4b6977767a636e4b797337505455314e5a6877423575495857733048456737694a2f734f50416539413553334e5461732f2b7169397257336978496b58724c674130436e675432394b71695a425067414e475a6f66674379536b47523079384441594764485232646e313846445238412f5634775938634450663446524e4b617177633732522b3634493479654f6f4d57577136383671703579383737383873766a313877662b72634f546941354f532b79495942506762562b66395645614c424d494a5156525775425171724b4f43334d4d49794c56463535616d6e5756322f644f584b542f2f367a706231367945356b7a55465950334b713234634d5745797762456d51456a6b4b693247496747684947327749413241484d3679463245686a71482f46764252682b77664c67454869715a417279424e6f536b47556c4e674b694253675263677a62486c6a56714664416f4e63577345576b52494135525556493246644d444153566b7a5a4f3355767031765076396b4e42537854374a75764f392b74437832302b59705335614d6d544b4a46486a51473561423041432b46684162576961487873722f642f4c356239482f6b694d4661413578416f3250324151706c717162446f636a507a632f504444515646632f65665a733072493657706f59676f674f3976583342446e4f6d5a72694a783063775641675041324e6a71426f4177567343564a756539344e4f547730416771475252426f5a416341506330414d7154527a574930777263416a49437479506a5139437a38457177516a676d4566676d5148305a546f41306175716d4a51674d5346684872432b7865393958363939384c396e6359594d452b33385858584a75656b585877365048736f754a357938366e48547a6757345a6a61447441414947553454585a7761452b2f322f522f3459496f56666643412f656f6735447a796e6f5075357965544a79636b38644f7a3759315456312f6c776e787a61634f6b6d61656c39507150626b36637a382f4e5473544973696462416373424f774e5a4b435936674f5454576a46514244425352444557673042343274595769334f6a68476d5358614778452b51613977396a652f68774a696c69476e4a4e42456f476f59484d305a73676f4153673348506e6e317a5732667251735064504f634a54696369316175724a772b34344e33337873786151724944787241756e6b4468324271502f2f6c367a3543763549642f462b6d2f7731482b70384a584b70683339644461447049556f386b446d7a647647336432764e586e4f2f576c4363662b36306b6778443475434b6673334c3535546463782b526b6d61614f7334442f6352314475794d7a414f542f64757a716e334c76377a714b377434414c624177426a544d4d4e566f41704b415748764844373933427847544d42334d5573566f36636e58336a7032756d374e366a583350667a4c6a4a4a5379696c45773146337168756b446a62346235445966364a2f6b776a747a536767696869716752616f34626755436a63635062526e3838625a3036636f696368586e33785a583974414d797a49724c5379387679564b38664d6e57303565424f33434452644261455144557750565a656b6638724f762b326f5a4f6c673262696d6b3770465153676444473739644f3332445a7436327473685444495556566c566366563964337a792f6f63477853363936464a66546a344e56676e67425877315178673666497a576e663762365838704676343932584e4c7571457a4c497469434956323173724f7933563658462b752f324c3079497163676e777845517350426f79454a415a43765331744b563666772b566965423667697757354f764b52344135747966303343394333336b4c654167624e36686175365047752f694d624e6e2f78397273444852314b4975353043354e6d545a7537624d6d705530643734346c355335666c6a42674a6b497a69494679696357394451303977683944337a32332f7536642f6a785761756754714849306d654939663056415754356947414a4a456479724a4439353851395849455a6465666656506237714e6a327678594151445a6c50302f4974577a4c6e34416d396c7559707247494f65466a42556e55336f3770662f6b6b426d5130633267514b424d74435330624c33304962335074793939737455515741646e4e507658763639472f774632652b2f38325a6161654631642f34514a786d545a41616a6359376e555842466937673143487967427a6a4e4456583337794d6365415a594138466d307752594c4167435148354331786d4161764168595569576f514632773267653353654a345361704f6951306c416d326f414e475143733477776e4a3665464e54514d3843656b556a744559686461716d7953454c677371424c524e5779436e35476f395444646c4372776f41695a6f666878344963734b344473305a5939623858426f772b667239752f6538344d37663969322b3943684c37357371716d56596a486135796975476a6c7232654b704635356e4551364d6457426f2b527141572f42706b4a7844534c506765716736466141505172426f3754474f6e71316c306f52694767424a4f5941644267675148494673574f4c714a35343574664e4138386d36444b6450634c6f4c4b6b6563633957712b6f47756b2f553131644d6d7a7a6c7643515a31516c2f73775754417350414849574341563841755139633448764a4264494d2f5a43705172616144667a4231445864794572434e6f50526f6e4956776741456e304251304e413351465a67792f41484f4151645969634a5954435774474b36686a515a306b796370544163497269753652676b43476954574e456a47414e496a6966306e516f3455634a536471786c645856317676766d6d726d6c364c45484971696b723045344c76427861476d7378414f514e456f747173674169424952754c2f2b7a634f4367676762386452624e6836714a5545695079716a54464756594f6a414f44757a56546659534968416864415436675043702f61487469744447416367334156676c4b4d48687a387231706d57752b2f547a6a4c544d796c465677446f784767494f646e57336e7a6c5448343847656462746461636965305a6249494259774a33592b6746344556674a4d45577a4c4e33454b4d6752494745774a545177523571716a696b616f2b4e536637693939735372542f7832372f6f4e5569435536764735484b357069785a567a70375a314e6e524567704f58334c756d436d544756344158555331323565773530555177615867506151766f4e4c6f546b6c37516771436779597268694b54484473774d43424c6b684b4c63775148304e68656d4a504d614644485152394d744d594c6a55465243634a694d495577524b54744f676d43694d58777542726f36652f713674362f662f2f786d704d704b536b756c777667417841594735696333596f68476f71463845555345472f597347487436323833376a2b6b68364f6763414a7538674972634b786d474e42576d714a4d52635959554f376b375545516c48434b49594f42634b72626953576b614666587074556674646331417354337061644a5968776162642b666a71705043677878416c515139426d395232756c686737734271464734426a48636a6e5a4f566b5a365a732f583063362b49584c6c366d71314e33584c656c714f424a7562577071716d334b7a5376675555354f6343787251693550456144714a6b4f496d4736786f48616d41596b2b542b6a51626849334d463341434e61303847673846677a7633376a35773564656741525568305343494231757a2b4a566c355a506e33713437765378557965752f3848747857576c48492b477a614139587a6351364f75675937386e4c5679776349413034496367474f69555a63414c41774a54784f372b35723048616e66735551777350544d5435416270724735716b4f4f535357573158554c79356943647356524c4161336d4463554b52694c4e5861304e72654462502f7667773030624e6c54506e6c46655867362f4138774133553065444458444a6877454b306b5332476b384867637671717271593766633258446f534a624c6f7751446a6a53334f7a646a315730336c7379624a5571716f5a6b6562776f594833546251684e3153423342673247716a6f654467633675583978355a36796e42364d3544634e2b2b4a4d484a31787750736f455150414d4378614c434d34415069426a5247547a4252453673506d545a425a59456968426144434571567239715a4f2f652f6a68502f337869644467344e7650507738427350626b535a4a6d6650365571624e6d586e6254545a7a66523654345646314a304c6a4f736a4b6b4b686a61484974474b316730484c794768664f4768635645557053447a57312f65767a786c727047525262426551427571706777386362373739757859654f3266667375752f726179724656724d65744962526c436f372f43485851756d51306859346e4a556e6f4f435642656f67704a4b5a536c6f4c704c4f543773674c4f352b6c564e33516550303054644a6546586662444f382b2f396b7154707941545173764c6252686d65324e55715759716f684b6e6159496c3848562f6558586675733169353441635355676b4e53676c6272333333675633334a695547636478494377342b447550697177516f694238436c4a4d487151364846496f324e586151717371706576682f7234394f375966324c4d6e4e4443416449686a4f4131534b62412f4569327974457a41494f426b6a6e373531562b66666b62733666557a4c4e6730414d5954783434425a764f6d704469634c6f4165594f6251655453706a6269416d4a426b524a4b2b4c55736f3449564d412b524f4d3037426e353479626348637a7a37374a424b4e6e6e665252517a444b63457770496d6d70545857316837666630434b78724b635473377670316e4f774d46786f33747a64625443473663733359475444704f77677548325979633366667a4a5330382f48526e7370786d7758573773325047726272375a6b35757a6674336e426b7464664f5031425a55566a4d4d42776f4f49425a314632547130783234637649437a484471794351304b6f44764237552f512b68394454305137543533362b6664754335326f645142573067324764375932316e65314e6c58506d496f47447443503059767433335574476775472b75715048643336365763762f4f62337a627350717230424a386b6f6f73783450524f6d54373379676674776e67585043574143676831634641526b7534622f49504c6868782b475435506968566377565a654c35306a792b4b46446c43717a757335444f36505261444459334e427770673574453563755a4b4b5a4e353433775251744864505539744f6e503333322b66626a4a31794130585230517a7445656f486a616d70714941306f79732b6e485134514f564a6b744367444c765550524967616c6e5332454335564e43414850305a4754424d6b7a785357466a6565726a3154557a7476336a6d704c703970796f4877674b5672536a5457576c73487279524a6f51334f4f52613444796b4c59526b73546a4361796b6d71324e566273325848756a66654f7235334c36597073704a4979664350484446712b6455336873583473644d312f727a73383635617861583463494255534d63746c4334675372714f6f655a395734527768415a34645074333648496d49557531652f6474665065396e6c4f3161525a4150356b484649445243536e6530645868793837494c53756b474d6f77394f524b48435555365774702f654c54447a642f754b5a6833774772623941526c53444a3057515a774564575a63576953792f4d4c4d346e4942366a71364f724a755758505036472f6b4653455a474457434b78386633566135373763307055636c6d456c3259786b67706a426f54654f496b782f76497873365a632b76316276476c4f533558444457656575503868746136466764694f64724d79464a59476a51417a43636b4b342f47556a68373977352f2b3146565759714b68616a5258683351525a496d65436777434258534c37737234706c3249582b4433494f41543645487a39766f46774a5561723172647459322f76652f4261315a654f6e72717950333764333731386470456239424a385770636775526b3072793546393934673673676c33547968697952486b2f305447766e71647250332f3572714c736e4642786733554a45465830466d6266652b344f63724f4b58486e2b42384c73767566574774504c696d4b465172414f684667786a45634b3048663633654155754241416b32435677444c344239416674446b62465649644178695254305465392f73624f4e522b462b336f455350774e436270456d36525864517a4364793475534267332f2f716e45326250416c4e69534b6237544e756e663331762b34594e5869586d4a3268574e515464784856445973676f69596c2b312b31502f4837636e4e6d5166764b59593667462f7a2f6f48365432496759596b697a494c7a68793542435745416e644a4256446a614656324e42426745535351595a6949622f506c564f53313344677746392b2b337438494353496d6d365a724e7331714d75307a314d32616c526d6269366b4371447a414f6d3262646d636c5a71616c5a314a47506f333049364768417336616f4e722b37345252456d4673683074497553723753464e4a46544e644c733935362b3434506a52592b75336276426c5a3631636554464c7331305166544577564b363975575850357330446a5530656d6e4d4c7a6c3066664c542b6e586533667249323144384171737037334f374d6a4774757532584a7173765737646978666575755a537375576e4c355a594c66693973374a7041556a59624130563449512f4a44562f2b6d51474d303545465552635851665a4d517a3947364e304c5665383830762f7a4c583956733253594e44506834495277633544784f446264455266597a516b534b67565069486479756e62743033526731616f797136582f387861384f374e6e72346e692f6f744b6936675166706567412f69575755747a38736c747647482f4f41703168444149537a332b79674f6f6669424179436344516a4d436c5a615364506e6a496b4352434d54797341484266564657533578797057624d587a6a333376495631446163327676642b3636476a58735555644e776753596b686369654f58584864395a4d577a4338714b5373625577555a564539627178704c4e445855422f7237636e4f794259364251494e676d5937734d4c6e4b426b534970476f5463412f6b69736a2b4246365131614a4d42453154454279666e70766a5445747061576c7461576b72476c553163737859535a484477614371534c6f7339376433394457333142773865487a503376597a545361454239504979732b62764f69636366506d6943787a394e517032754f6474664463386e4856444142704e484550774166616745415146485135792f6235396f57426249454379444a4d54596367436941516d67324b4a5565444237647333664442682f5748443250784f49765530794a70537249302b42726538424271554d364231736d4237434d4441556977536b724b764734507850764f746a596668436f54544130534e6974426d4a4b4c49374a534c3776334c6934743353516f315441643974594b2f775839417846694376683442446f4b4367766132397041746457457946474d77544552414f38736463475631387937594b6b6c5278392f394664746834366d515462584730353370775167742f65374c2f377833574f6d514f676d6a68343443414b614d486c4b704b56746f4c306a314e7654566e38364d6443586e65376e6543384261427767766f356d67774665416f65534967526d776156426841697a5166765145795251775851622f784b455a686d4d793547576d6c6b3963567044533975757658763456502b794b316268546c62573545426f5549784849596b63474f6a72442f5a4c6875724d5343306358375830716c555a343859657161336275485862796c56585470303133352b5269516b4d53687a52426b41615768454d57674b326146385843517848512b476f56586145426d6c4379326953747041566770386c7849484275673062583372383866364f4e6b6d4b4631654e7a42745271676c6f41784f5077776d2f386273386b70714174714f454f5a37674d56494a78342f7650544236347551785938646d354f65644f6e595553385367425a41496b4451744f7a6b6a3362766b786d73725a3878513453534c46454430663574432f4766364279496b496871615a3650705544774d726d2b77717a7330454142453143764856516437796664756e4c64346156396635384d2f666143337138327257536b577a55555643627947532f43504754486c38677348426b4966722f376f6a546665624470796246527861556c786363322b66514a4e574a725332645234644d38757a614164724d4f566b6f72572b594748684661694d69512f6549564469446d4966386e334a67704f7946596738794f4a714b37534f41334a7970674a3438644d6e6a41516a7a3333366c2b7979776f576e37396b5246566c51307344794a4c79434345744d57482b72457476766148366e4c6e766650485a3866713638564f6d5876753937336d3961517a4878335846644c435137384f46476251724b4a35452b616741416234457a476744422f54664669453463774f5364306d6d484b37395737612f2b7076664e583636446f4a30564978646564734e637935665754476871724a36374d4544422b6959516956304a385830713247516b4943575a714174797748452b7a792b727a356236793349713534356664545930636550485a52456b5855494356554a3039626f42624d7675764d3245624e596932566b6e4358514a4f5a2f54655250482f347057712b48504963397547455a6c4747665a6d6f636977506669776f4c39332f357052524e384637666c4c6e7a6c743136572b42457a536476766a485931733442614a5a564a525a4c543038506d72726935474f3475576a6c526255744e56393975696255334c476b736a72446b374a707a6364424d526f6a564a4f79484335424359647261686f6261326f784d5a61576d63344139414438687a706f794a6f47486755514635674339427845614f6736744135486b34415757684748593342426c6d5534744534637153634576634c536f696e5470707970727a39352f475243557136343471717930565575722f654775332f6f397670714768707236756f6e5470357934525658465a65567379795063423161676b38624641627569344a4c67544e414e2b47674857624136356d55665438336a6b74496842596b43786853477374497841462b37392b2b3439316e6e392f3436647245514a4249794446566d33584f4f656666634e4d72547a2f3136667366744465316553676d31745872465279794b46497375677463566d584430714839414e6f6b7341524661577071696b55694d786373424d4e744f586c614455664e5348547177726c4c7237304334796a4b4a566761546c4d4d71574536654374626b774568416b76416c304f7645534f41374266796f59642f41722b41727a584941335164524569493446644552597a30643578704f6e36346f2f5a3078346e6a756d706d4642517475764453314f4c793162393974503767495464474d5a494d617078514a4472563236744b426b30374f65666357656630573332744a30396733594e6a53472b387337653971794d686b416b66326966426c2b49786732474974346c67734b57784c6954484d5a5a302b747a3231437575476643587445776b54464e4849306c7761467343326f7362576778435136764f774a2f434e31435134774d6b514c6963726f7253436766767171747462473770544d73754b43757661477a765048726f534770613575496c353156576a526663586b67384543514856554135493152436f496b533042423763412b4247485133444b34517541696f7a6249554245414e3074416f58545a696f55424c793445745737373836377564396330565261557a5a383370367535564d587a6d77735546355a58625076676f336a4d673977307134536a675961674d6f52694d5653422b417654684352577966387a676156714b78696d57362b76754b5367714c5a383176656e51735642546d312b33556a4e39476f74483959544b7749555a3341446651306f6b784241544c616447496b52726859414a70714b427761474f67427a31754969476145465046454f4d7866566763504f486e3534386661792b385a544157576b7369536d61692b4869427534654d654a487a7a787a7572372b33522f2f4e443434434a786d54554d52457a36663733524c61306e6c7145464a4e6c6e756f57662f5a506e3139353735632f662b6d7253417862746452654e47485270734c366f714f576647394b63652b5555754b446e6c4445586a424533464d55756a7142486a786c333767782f34636e4e41684970682b4c4b794c49514e4154366775394841596c6a304148303053473637436f51574b62546f33586178746961437830553743365068556a4c593166333669793866503333303347586e727278734653536d3844744a6c48695847385344547265485634416a5542422b73654d6646466c53345879514b33677656546656684f7a686554305274364968434b34312b2f642b2f50344838566938703676483630752f2f6437374a316450654f2f56567a3964742f62713232356475764b43393135396164663262644667794d337a4f4f4277614b71693471494d3367497571796d5351454c67785147346332356668795262446b666832444550767637384a34382b74664f7439314a4547534e5630637546614b78646c6a315579716a384559756d7a5339664d416653664d4874514474416738634358614e7045394a514e4535746931413830335a6f393734543233616141625359713675356a5846776d716d59614f38716864555655486d65343449346d547132367337662f444c4373372b2b36444a4b31625345364958386e6942464d6246732b5972506475774d51644c716446352f3131336a35302f3538703050506e762b74564a4842696e7730355975576e446e4459516c66764c6e4637393637774e504b4b46684f4d4e78716d7167465565436b3364377750756e6c5256506d6a336e6e457375736a6a47596947374e6c5646343942644c30513046686663486c743479466141396178703062594949574c424b36412b553955315143586748796e4b556e585a557342505175344a32514a59744d766c74743050456a38554a4856626a714141714e6844746d4938357541636867706351704f59684b5268426c6d2f5a634f2b5864753757357561472b736762674f364854326d716e4c36444355757061656e624e75346f6247706365363569322b342f54616f38765470327562617570374f7276616d356a67304f685379346a454f636a7553556d4e78467a544d74475464704e7a7575494f506d736263383564643966435033337a3431386657726e64485968536d52416b395152455352516d36344452596c38564b4e4a61576d2b504f534b4d7a557565754f432b2f6f6f7a79756855635231734a417059474658516b74414f62742f6257314365366572524179452b7a7741774f743844435746337a6b5a4362574d41586e574a436d456c3433434f6d546778336458523364577136786c4d4d7048535a32626b727237742b376672314f6b5031524d4a7a6c7977754b536f65614f6c714f4659546a307534327a6c32377179384d534e374f6a73745365327662794b434d6554686162524468524e48442f53784a416b547463482b6764597a5a2b7271616f504241566b4f5138624663367a4e626554384948625a72455a7667566b554742774945776b50665143665178524150775043435531564a5241757a30497162752b5a42656b73756b4d344b5430344177526d622f646a623347494c424d563843755972706d535245724b5146504c6d58304831372f357a70373158375458313466362b6e4c533079786459306a796e4d574c786c61505037526e563164626333395065304b4d396656303557526d4143544a796338764b6938764756383963734c45716b6d5473334e7a673547414749746975736c614a4d7277634a4953684a4173417241767143692f2f4f596277704b345a66556e55762b41477a4a53565547726b38454c474c6a665a467736786f674b67526e7863414479735936326c72716d686d4d6e542f51472b7030706673376859426862684e4d7171344c3966515363624a6d47707441415a536c303677685950716e726a47707745504a6c4a5348725955555a6945586e4c5632635735436a79464c7a6d544d387a594a5a54356f354f7a3872353675644f78525148397938364e6f723035777050616650374e6d786d7851633478664d5858376a74535a467650446f59324967716e54316d66305268645a4d334b52786a4a6252474b6158452b5259484930736d337037562f76424534645048396f54366d797a564a556d475946314d42524c51646f474158466f6f79414c416869534a3052484541675343336853394f416e65386f46704159526b6b49544b774168514b36516c71486c6241544b542b7a70505367554144644c7054415443734b35594a47796f6753433366574e78372f63394d57726236373734494f2b7a68594662634270465a59574c312b78764b65724b7847506e366d745858626530694d376439596450786f503967484141634566334c736e486f71493058676b456b736b4a483947546c374679494c5359705053756c766174626a6b51412f6e7733474f315a435245546d6a4b315a6564555852714d72332f76784b2b36476a474b51636875586b574968366d6f7075784746316a44597379484e455374554279484b6b434e34454f4f486749364b6f346c687152727262446134466674452f474f337637576c6f71447432394e69424136655048632f302b77434441543934772f51706d494352486c6f4971316f767267644a613879433258662b374737494f665a3974656e5066336a61777a6c3554766a39752b2f6563393031426b4f4f6d547a78757474754d594c7970322b387657764854744c6c767658424236716d54586e6a7865643372506d5969635335684f7746672b4e466934514154376b4e42746441643944577a516d4263575a6e4d466b7042357361505045516f774676794c7a79306154674b613063732b7969533177704b595167714d46424f6a30563547664b4573487a4a6d45524c4a4f495251576e41347a4d55445849546745456f7658784a49487556794941784342744254694967615761517a6376496f696e78534865716f70735565542b545a7633624e34573675344c7448667a71676c326f41696b6e4f363438764c4c557a322b61445357377645392b6574666936475167325766652b4576727a37396447504e53564f4e34785274677432447838597067324a34747a6359457a4d4c437374476a6237706762756a59766637662f685437613644564551694443746f79687050466b3859652f75443933747a633436735866666d6f793967435a45306a4179764f7844756c7a475539577167647742674d554a5839554665487a562b2f4954703038717271727a354259497668524763614e4147724e625758787836594a6b416e52516c456f344842695042345034744f396f41387a62556d37473454376263466b6e455a4a5a6964516362775853527873746d6a3139793459566c4a65554864753737374d4f504f7a75374c376a6b6b6a47544a394d7335636c49632f50633576632b58767668616c4856626e726767516b7a5a7754446f562f3836483670713865744736776b657730384a4367574741564542654165676f5a30776a4470724c51784d36657675504e376e362f39354d5437373062624f794473697a6972456177724a563032736254304e492f58553569543563744953636e4b53693875397668396e4e734a4d6f4e384561586d79452b43613053594165514530524730486e304130562f54434d43774a476b7053717976743765764c78674b784b4e42634e7a68554c43377178766754434959426936484277666e545a6b4a576c3036705872433952646d652f7937742b3363736d5872646175752f50507648704d6a45554d5558333731316465666661627534483757554f797432634273794b51494538424c6b724a596a754c34566264634e2f656138313939364e663776396a7355414241556c694b73327257354c6c5858757a6d32473172507437797965654f5067305366784d7a59346d59493930725935614d6d776c64382f705379387372414f695654422f74546b317870616144354e4336416254484273416930454b45713648446c4536685758514d5141446e393656372f615a5a50484a4d533376726e74323744327a65456d2f7231754f71332b4d325a6431534e512f5047474c692b4e37396d7154636374635070793565464e504e4c5a753276507a4f3235645a566d462b4874632f324e645176332f444a74335164464d624d3357535957676e3975794a647663364e4a304278343147725578776435713970526c4b6e7946326f653357756254796b746d5858456759656b5a75446b745372494678467348777a7054732f4c6f7a72526246744b456e506b644f4f7a694277543246686537736246397169694d74425a782f626d3475492f414f6c756359687155594e38746a4442666f36544d70556c5a5656564d56535249446755676f714d6e6f6f4c4f6a593242774d42414b36496f4b776f4d5464566e6c475359744c58333273764f58547072362b7575764e76563078486474762b4c534b3072476a32337136685a382f7068756f4a6a4d386871594e6332414a774144544935415146416d305a6163456d5478464d75483051333730744739653664666649344f46677242497455666b4d544a382b6173754f3479792b663436352f2b314c686a6a78574e4f3031477738794571654d434638557774464d644c3477614e57724d72466c6a78342f504b7974524f4c53594136344c4b544d6f4373674e5442536c506e5a6342384a46414a396f32686d68616e74784c555a6f5446534b42794f686a4a7973497a7532626c79397075766f43556334706b596a717078495330385630594f51634d7670754f733376383466505359757951383838434132474d4a44555266304a785456335352453655656665615a6f7771536a2b77342b66743844325536506954596d4256384c4546466c634e72476f6f4c474d6a46646b7a474d38586c2f2b7676665278566c784f7a5a477a3739644d6654663479327457474d6b446479334556332f72436f714f52506a7a3157632b7751627371454c6c6c79564864364f6b50687a4a7763795051686667514341622f624b3042734e6b777048454e442f686247657948663859706948464a73703873684a574b41624143324b6f727339336d6476725367704a646c35302b74724a6f77615371743642733366446e39676d562b6e397371796e377870526332666636356b5a422b387576666a613671466c4c53347233396a39782f6630746a5059305a7a372f392b7564767658467737566f2f474471437553424473435353646a705473374d575858444245792b2f3450523672727a315a6e3946775a50332f6a77784548597a7267742f2f754d4a6932596b744f6a6c5631325345596937517949626855444c6844474454552b4a414f64545571764754377a6d2b707453383473436f6144443765546344745053375777566734414432522b496a375344656e4936444552492f757a686e34456a6f44454b47624e6d4761714a5253324145426a44716854613747444b724f6c56343866726968674f42315254683477546836514150424a4e39327671694d6b544854372f696f7375376d6e724847787277574f697879546a4e486732374d6137377a595469553966667950524879446945716e494f4871716a776d704d71385375476f42316769496f6d67592f717973372f2f36562b733362477873625a737963584a7a625833543466324b4a44705330384b4b586c6778496d2f63754b79306c4e4d3152776348756c6b61793833796e33766852664d76757151674c625730754b693473474455694972637448534944316f73515771616b324a496c6930714c343245513058464266434c7a4f77306b4a386f4a78674f484a4a77793131337a4668383774583350646a52324454593158746b362f5978315a4f3262746e342f7572333470695256566c614d72484b556c53754e335a3035344843334d4b3031457a4736666e386f342f436b58424f6275366b3671724f7a74614f3168614147736e52674f537271437242654c5234544f573174333976346f78702b30386366656d6c6c36534261486c783265322f2b753249435655785447767361746d2b6434635153704342534c37484836477442454f595875663531313535786531337a6c75796c484e36494756676549464339313668645643416d69487567597a515842464944706b684d6a2f34693054343830642b446c386a643234505571416c3067444c47545161695446556b69414941514c325a36516c4e4255417352535456595a4a7a63752f394937627377714c574a35584e47316b61586d575030574f78494f4251414c584d59724b79637a4d79733037632b7834704c396644415a5a7750595544716d6753566d63544e45344131344a734a6d516c6a4c76676855417464642f38586c476176726b7956504f6e447a64637677775143704a30584f4b7932597557735237335a36637a4f5048442f563074446a426b4d505236686d7a3038764b6a783037756d6a567168466a71714b39665556466852506d7a4270645561346b7047687679434b704a53764f583744716b68466a787741414b5273376474723865576d3532533064725a4645724c536f61504c632b534b4f762f66485a7a70723636506855484e546658386f494570535a31646e5a6e3565396f67795342426164683773372b6f64374f6b724c69743365373367716470374f2f736a672f506e7a773730394e536450456d684a56623277414c6159774f393671595a4341776550586e79794b474470303665436d764742526463736e446c68626b544a3044384d6c6d5364516f4d54626364725945634978694a6b67553556584e6e4c376e69386a6e4c6c676d703654516a6b4f43695358532f42787038775845576f446a4b345546794e6f4a423867504a6763366744354149662f6e494c384852496d774450344e7a4149537a36493452686949344f422f306761416f68694d637a7678783153506d7a47735756636e68644259565833546a54654d6d546d48524d6b4b63597a696e773546664f534b7473754a6f734338656a414e30727a33644f4c463659717266792f463062564d74354e6f6132683766414d55674e41464e4f6d7161365865585442692f374c71722f2f7a73557a33744852574668524f6d5461765a7662663178416b6170326d4c4b683835657479556958423679716943376e42766263307049704c496a784d5645366433642f653863326a667769757663727539762f724a7a7a745048382b744b7075366448465751566e4e74766f4543436f6375666a42753175374f762f30374a38436453324c4c37696f754870636772523248546d61597a6e4c7831544a587262356979314b6345444270456139503652476e4c4c756a2b6a426d76614d67734c53305a55464977763237397a5631644865303930355a636d437a444646686f7661636e444873746d7a72594651336446444b69307270674a5248347762755267305845644955536e515052447244334d4f37344a62626a6e3369737654793074784469336a41325936534746553853694635446f6755366763506633535663757575614634544458424f686b475144704a514d5a4d346169677853316f4352444b684f77354d424166464874476245682b5349542f594c4c7062386d307036726849486e7a3163795a4d78664d6d623177365a4c43386e4a4c6830694c6f38554b6f41466f71427850796336634f57736d69394f48392b7a4e544574622f666262335731747034386552796d4f5962456d3767415870786f4a2b4b3254342f7a75796b6e6a6c6c31312b657133336a7877384a42755771556a4b695974576e5434304b486d32704f61496d6d714e6d4c367a50545330742f393470634c7a31394b5538795a553665443366316a79796f4c78343364652b5277434c63574c7a36506b5a54316237314c78714c317a6655464979744c7830304d4e66643339335a52416a3339764157446763466a55486b34356e4d34537174484d7a7833594e6375616a4468796336736d447a35354a66624f6c706230613336504849527247513663536f477964396754336e56714c7a534d6b377764586230424b4f4a366c6d7a575a386e4a362b67713773764c7a4f6674616a6a4f2f656c3461515435796c774c4243703047496f496f356a7574735259504252633266652f7274666a5a383569784d454e48594f686d586e41446f6b75777739657479344257444c7332614e4754384f506a514d672b4f476c6c6f6c7665522f6e3542732f6d7543476a564e673165487738487a5049695439336c7053464556695144564933424e6b5a46436f4e5870614a7a4c365855765848482b4d322b2b586c343178756c326433563079374a43453752416336514275416f5863505334486f6b3254513566657455566d6d486971753531754769473554772b5052355663464f6a69616769596a525a6c4a7662654f79456b3254364f2f754c636f706d7a4a70507572792b6b5a5765374f793632744e6570785074756956715a457a6d49444f4c5331765866326e7161766245735954414968576753476974782b734e686b4c52514543506930364f787a557a46677846426f4c6761787a706d517a76634c6f38353878654d48504b4e4945424a3064794e4e48663076544d62333664694d536d7a5a753759745571364c3975574e46516e4d4c702b332f345146466545637349344b47777147374764514b742f324973687064705775535a7250466a3776336a6f356663667865666e6f4973514e6441666d69644a384152793649464161337078797a423558536c706b43656b32517357416a38646f6a702f785036357949456d63466c344343357377646352674551614a6b67504154456b507546622b4869614434552f432f4930756e333570615758482f5033557376766a69336f45434444454d7a41436968485578556938466f6979644e42376c672b5a4a514e4e7a58316a5a39347553724c3775696375516f5475424a6e752b58786241713453776c36557075586d35505279636d7152323154537847563432664c4d4c3138764a4e394d696e694674776f6a56536b73596f706758494f424b5042594d365132586e5a57635846554134317a5356734377426d435149454b6f675a455344495959676456454f39505448513745784579624e58334c656f6d584c3538316656465a6352714e626865566f4a47434a7362375731673958722b5a633775725a73385a4d6d4b675978723439423034647234474d4c7a4f33454c496445427476734253614461494e417a32626a2f6237783832626538325037683035627861586d3458355042534e484349536e36346a5177526532577477494958566456314b4a43446c6b53514a654a746b39662f554249482b75516954613939416975424667525530445247584a316d47466e686773574a714a45736259497359577665753435594b494e6a4e59436c435149307575664771482f7a2b6c316666647a65626b356c674751444e717541595548556d316276306f75554c62376e78733665652f66795a463735342b5732396665445753363561746d675a627048414e597968635a35782b4432437936474851724775336b327676397662314631534f7471566d65756f4b47397161776647354b566e3061706c68684d2b6933615a4a4750687a53307447706876696a746d71754659464c497a337550322b6233674730654d7278594e632b324848356d53776d466b7547665159644c6a5a6b7a50723667514a665658397a7955372f4350486a6b71726f675a6d58346d48725836752f657458374e68376275436c37376a6f653858656e6d31712f5831332f2b574136415236445635504b596d656b303834584448484b36457935303274757275787836372f346e484338614d4d526d4878516f424f515a4b6a7836645452454579786951496571366e45694175344b3377464348797758324231786c575262596d30676b6b747a2b4839452f6a345741534a4f2b4649354254554233444451597155503867362f51654166614a67627466495a4479495366456f526b477041753856345078544e43616b7278754c466a703078314348782f4c48716d71354e304f7468557438666e537a5878375a39397063556b55314b62366874333774344e5562656b71484450767231643961637457533476717967754b5475356436385553777a3244325157464a534d482b64784f76794675573148447455654f31342b61654b6f30574f6c3975346a477a646a757152374f53453766647243525962474e42382f306435385a747279525a6b5a47626d2b6c4647467055566a7169676e32334471524e32706d6a534c4363546a35367863675848734f362b39756d6637446764426e547834714b4f6a33655631476143464b6f427577755868447533593575626f6f6c456a5359377050485869314c343932395a38714d6e7850527658445961444b6975776d576c6a357378596463647435393130513170786f5555686867415861497830556d69484e7a4137634b45496941424d704569615a63477467544e4448364c374342433252473874433849687344544a3976382b2f584d7254424c6f534c4a32734549514a4a726d734d634855414649545243513033395430475a6d6b5069684c5551496734594d6b6b67764c3535393965577237723372677075766478546e68324c7872395a2f3964356633394d316e5763355456494933594151345855344b6263624c5a7654544a5a6d5234346332544859323937524b6b6b7876304e6f4f334663366532644e6e38757a584d4441345051494c664c52624373624b49375341694753736753777a49734c3068695170566b676556776767512f56587636395074767672333773382b5561477a5a785a663476543577734b6f6f596e415759666d7a307446644b4a494767714e594e71357245526b694767757854757a70494b54492f6b337275303463697261666b554b4465414a4e47473561753661357063475a3452753559505a4664393232394a5962696964506f42316f797a343056774c5a45337165444a6f4f412f6b6872555a414158454a336954355361426c41386732344f6677466977424b506e562f35542b75794c384e7345352f3355424c51544961574345436f5567464970534141616b654d706d5437766b2f7275762f3958507873365a6c3571563339545245394d4d445a724f515a5a49566c61556a737a4e686a366d59706948594578524b3632734441563642364c397368343335456a7a73554f31422f5a77454f4845614b692f333952305a506f734a524a6d324143345448412b7479636c4266787762334e625a314d7a5a4668694f4371775045745359694a2b624e382b694c767065626e70575a6e417330516b31464e6267374659566b6d2b5a47695a71656d71704975474e66586352626a4869525a3079797245577a644e3168382f2b66617a54373733702b63327231354e4b477136423941636c7a2b323873493762727278317a2b5a744f4c636c50494378556c704c4747674c6665682f7859427032766f51535949365033583561774a4750342f4a6a51352f6c385741554f464239734662594d5030424a616b6854634b6b6b6c4b4b4a3034735262376e33676f6165667666566e503073644f3672646c414938316d754a6532755050502b58707a353838766456355555564f666e6a796b63586c46554d426e6f54706b693553464743324e702f384d76507a4d6a41774a6e61524341414b7032566c364e705573644164307035496535334d6c3558396652706f633675364542594455583967677669496351636c68554943772b487777417330624a6a6759657737664534316e37776a714848306e4a5377552f4559776d5334707a704765666463454e4b5354484a415468315a6d6355643361485363473535306a746e714f314a4a2b6957507731743937396b7a2b39664e6676486838316179374843775244452b427a4f55596d774b674e6734444f6776596d7933415135762b552f6e6b732f41646b33783379587841614c7253584d67435830514a4e4e4b706d6f6631336b6665486e6746596f563065723976766d7a4a2f7a71547055314c7a7367334b69735a44676642675931314e6656314e724466453036786f4b674e534d42775969455743666859396571532f7233666d755976323774765a6576694549696d544c3179656c702f583146432f612f4e4754593156544b6c657365707968755466662f4c5652462b2f7153716a35307a4e4c696e75626d343976476b62684f79525536757a386e4d336239786739495541667245384f586e6c5568304e637a746e5435673561396f4d373669796733556e6a78342b7945526c58565168333946636270586d52315a506d546835396f4c7a4c6c78312b2f667a7834376a4d314e316e734d343373576870646141754b4679314476774957675641626768757944484f557a332b4e2b6e3459675167752f664f594f2f4b775267485442484e416544426847674c7843754354542f696b5956444c54744e596b4733446e4734584f6c5a4b57586a423164504b4c4536334f6e702f6c697358426f734d2b4e4365484238496e61453030394c624b536345475969596f51666f465a744b6e3378794c644e5932704b656e6a7a7a33486d35335630396e5231644a55555634772b2f787a30374b79503372766f7a4f376167446d473670634f576471546b462b66327637795a3137515a46794b3074486a4b386943534c5733436e47776e506e544b654c4d727437423352525533716a4858583132773773336e5a77747942776a6f524f5751546e3842534f6e314131592f61436c5a664f5862517374364c4b346662686e4d4e794d4345634d3348536866776d306b754962616f4e38564233305967706d6a51415875442f624330326e482b5768424452304f472f6a36414e6b42346848494475336f36327462556457626635344c5964666433644c43515a70756c676155775744536c4234356a58365941384f6143726c5250474c313932666c704b4b7371554f6435533962723942395a2f386d6b3445415173597a416b654d746676666d6d302b2b33464f563374393057446f564555617973724b7975726a3531366c527a6654326d4b6d412b6b4a51426e685938766a433849794778427a644c6a7167635058504a7771707a5a727664626d6759714343304c516e4f687872392f78723666345549675942485149444b67456551366c4b5351537061614843677561577076364f39743732396f655a345830646250427a695764724a38775a464b35614a64727655444f41725131494f68674f4c3179535a70576864302b4b61346b373151373456693857675a7369392b7676376e55346e79414d45435141626266686b614848702f326e6e696e6262684b456f4353464145734a53514e31434a3233713039366d2f662f58544576627264334b61494954592b79653436744a5778387154644d6b486e71466a4150594d66666779376e477673704e5a362f4b367533377977386650353356463974336c7866624f6c356c4e6f6d436c4636544e41384e4779462b6b42464261497942667557526435724c7736774770585775312f645875782f33742b3333753465373232383356312b766434786c3652316851476930506e584b39636176332b5067427a5464543978387451422b41412f33694134552b5434557a656677707545554a646e695458332b7571367a386e785a565a757a7174695569364b4142655263566b34764457597049344b4a6f437a614e6b495578774b6836456a79674c446464326d36514766534a34553345343642317a724c43664a63416d5748695a337166626544665037534e442f563461446168333354716b50584e67327130684d333241452b526879474d495a4657514c4354566d575656586b65624864686c6b433073676f427a5a417971384955647762323356716e6566486f7a3770553534744766584e6930416f4c5279566a414a4359415a4e69636d43706944374139696769324e3067734179307263396167562f67454d634a4569677534797842727267724f3337486d41764579366c39474d4e6e6a344654716b7558612b525a37583877416143346631723579796e584c6b68516d6d356e49527948695849774f66476161574f345452594c626c6957637737716e794238446d525a6b674b545133476d53474135624e6533624e5a794b46684e4261516751475336666d6f45586839677650794e6f434e373851534e412b6c68734542424834436d7872545278486e56424e672f6774487332416e4c63644d594b705267357961774f2b4a514a75465176746e4256634b6372447a4c33546d6277544f6f7a6966304a6858476a584f444648456276436f2f54724a464e3659354348496f505354472b4e72386a66426a7a383258433062524649632f65394f3354394c45447743683479795447465134735941414141415355564f524b35435949493d
\.


--
-- Data for Name: staff; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.staff (staff_id, first_name, middle_name, last_name, po_box, address_line_one, address_line_two, city, state, postal_code, country, email, phone, type, year, school_id) FROM stdin;
jsportsS01	Southgate Sports Ltd	(James)	Williams	PO Box 99	44 Carter Road	Southgate	London	Greater London	N14 8IJ	UK	jsports@gmail.com	+564	SUPPLIER	0	S01
jdemetriouS01	Jason	Demetriou	James	PO Box 22	25 Wilton Street	Southgate	London	Greater London	N14 4ED	UK	jdemetriou@gmail.com	125654	TEACHER	5	S01
serskineS01	Soraya	Erskine	James	PO Box 66	20 Hardy Road	Southgate	London	Greater London	N14 5ED	UK	serskine@gmail.com	54654	TEACHER	6	S01
jamesS01	St Andrews	Dinner	Ladies	PO Box 44	High Street	Southgate	London	Greater London	N14 3WS	UK	sam@datam.co.uk	54653	SUPPLIER	0	S01
S01admin	Thia	\N	Kunaratnam	Post Box	Uk	297 Chase Road	London	Southgate	N14 6JA	UK	clubadmin@st-andrews-southgate.enfield.sch.uk	02088863379	ADMIN	0	S01
\.


--
-- Data for Name: staff_subscription; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.staff_subscription (subscribe_id, staff_id, event_id, leader, school_id) FROM stdin;
47	jamesS01	47	t	S01
48	jamesS01	48	t	S01
49	jamesS01	49	t	S01
50	jamesS01	50	t	S01
51	jamesS01	51	t	S01
52	jsportsS01	52	t	S01
53	jdemetriouS01	53	t	S01
54	jsportsS01	54	t	S01
55	serskineS01	55	t	S01
56	jsportsS01	56	t	S01
57	jdemetriouS01	57	t	S01
58	jsportsS01	58	t	S01
59	jdemetriouS01	59	t	S01
60	jsportsS01	60	t	S01
61	serskineS01	61	t	S01
62	jdemetriouS01	62	t	S01
63	jsportsS01	63	t	S01
64	jdemetriouS01	64	t	S01
65	jsportsS01	65	t	S01
66	serskineS01	66	t	S01
67	jsportsS01	67	t	S01
68	serskineS01	68	t	S01
69	jsportsS01	69	t	S01
70	jdemetriouS01	70	t	S01
71	jsportsS01	71	t	S01
72	jamesS01	72	t	S01
73	jamesS01	73	t	S01
74	jamesS01	74	t	S01
75	jamesS01	75	t	S01
76	jamesS01	76	t	S01
77	serskineS01	77	t	S01
78	serskineS01	78	t	S01
79	jsportsS01	79	t	S01
80	serskineS01	80	t	S01
81	serskineS01	81	t	S01
82	jsportsS01	82	t	S01
83	serskineS01	83	t	S01
84	serskineS01	84	t	S01
85	jsportsS01	85	t	S01
86	jsportsS01	86	t	S01
87	jsportsS01	87	t	S01
88	jsportsS01	88	t	S01
89	jsportsS01	89	t	S01
90	jsportsS01	90	t	S01
91	serskineS01	91	t	S01
92	jdemetriouS01	92	t	S01
93	jamesS01	93	t	S01
94	jamesS01	94	t	S01
95	jdemetriouS01	95	t	S01
96	serskineS01	96	t	S01
97	serskineS01	97	t	S01
98	jsportsS01	98	t	S01
99	jdemetriouS01	99	t	S01
100	jsportsS01	100	t	S01
101	serskineS01	101	t	S01
102	jsportsS01	102	t	S01
103	serskineS01	103	t	S01
104	jsportsS01	104	t	S01
105	jdemetriouS01	105	t	S01
106	jsportsS01	106	t	S01
107	jamesS01	107	t	S01
108	jamesS01	108	t	S01
109	jamesS01	109	t	S01
110	jamesS01	110	t	S01
111	jamesS01	111	t	S01
112	jdemetriouS01	112	t	S01
113	jsportsS01	113	t	S01
114	jamesS01	114	t	S01
115	jdemetriouS01	115	t	S01
116	jsportsS01	116	t	S01
117	jamesS01	117	t	S01
118	serskineS01	118	t	S01
119	jsportsS01	119	t	S01
120	jamesS01	120	t	S01
121	serskineS01	121	t	S01
122	jsportsS01	122	t	S01
123	jamesS01	123	t	S01
124	jdemetriouS01	124	t	S01
125	jsportsS01	125	t	S01
126	jamesS01	126	t	S01
127	jsportsS01	127	t	S01
128	jsportsS01	128	t	S01
129	serskineS01	129	t	S01
130	serskineS01	130	t	S01
131	jdemetriouS01	131	t	S01
132	serskineS01	132	t	S01
133	serskineS01	133	t	S01
134	jamesS01	134	t	S01
135	jamesS01	135	t	S01
136	jamesS01	136	t	S01
137	jamesS01	137	t	S01
138	jamesS01	138	t	S01
139	jsportsS01	139	t	S01
140	serskineS01	140	t	S01
141	serskineS01	141	t	S01
142	jdemetriouS01	142	t	S01
143	jsportsS01	143	t	S01
144	jdemetriouS01	144	t	S01
145	jsportsS01	145	t	S01
146	serskineS01	146	t	S01
147	jdemetriouS01	147	t	S01
148	jsportsS01	148	t	S01
149	jdemetriouS01	149	t	S01
150	jsportsS01	150	t	S01
151	serskineS01	151	t	S01
152	jsportsS01	152	t	S01
153	serskineS01	153	t	S01
154	jsportsS01	154	t	S01
155	jdemetriouS01	155	t	S01
156	jsportsS01	156	t	S01
157	serskineS01	157	t	S01
158	serskineS01	158	t	S01
159	serskineS01	159	t	S01
160	serskineS01	160	t	S01
161	serskineS01	161	t	S01
162	jamesS01	162	t	S01
163	jamesS01	163	t	S01
164	jamesS01	164	t	S01
165	jsportsS01	165	t	S01
166	jamesS01	166	t	S01
167	jamesS01	167	t	S01
168	jamesS01	168	t	S01
169	jamesS01	169	t	S01
170	jamesS01	170	t	S01
171	jamesS01	171	t	S01
172	jamesS01	172	t	S01
173	jamesS01	173	t	S01
174	jamesS01	174	t	S01
175	serskineS01	175	t	S01
176	jamesS01	176	t	S01
177	jamesS01	177	t	S01
178	jamesS01	178	t	S01
179	jamesS01	179	t	S01
180	jamesS01	180	t	S01
181	jamesS01	181	t	S01
182	jamesS01	182	t	S01
183	jamesS01	183	t	S01
184	jamesS01	184	t	S01
185	jamesS01	185	t	S01
186	jamesS01	186	t	S01
187	serskineS01	187	t	S01
188	serskineS01	188	t	S01
189	jdemetriouS01	189	t	S01
190	serskineS01	190	t	S01
191	jdemetriouS01	191	t	S01
192	serskineS01	192	t	S01
193	jdemetriouS01	193	t	S01
194	serskineS01	194	t	S01
195	serskineS01	195	t	S01
196	serskineS01	196	t	S01
197	jamesS01	197	t	S01
198	jamesS01	198	t	S01
199	jsportsS01	199	t	S01
200	jsportsS01	200	t	S01
201	serskineS01	201	t	S01
202	jsportsS01	202	t	S01
203	jdemetriouS01	203	t	S01
204	jsportsS01	204	t	S01
205	jdemetriouS01	205	t	S01
206	jsportsS01	206	t	S01
207	serskineS01	207	t	S01
208	jdemetriouS01	208	t	S01
209	jsportsS01	209	t	S01
210	jsportsS01	210	t	S01
211	jdemetriouS01	211	t	S01
212	jsportsS01	212	t	S01
213	serskineS01	213	t	S01
214	jsportsS01	214	t	S01
215	serskineS01	215	t	S01
216	jdemetriouS01	216	t	S01
217	jsportsS01	217	t	S01
218	jsportsS01	218	t	S01
219	jsportsS01	219	t	S01
220	jsportsS01	220	t	S01
221	serskineS01	221	t	S01
222	jsportsS01	222	t	S01
223	jsportsS01	223	t	S01
224	jsportsS01	224	t	S01
225	jdemetriouS01	225	t	S01
226	jdemetriouS01	226	t	S01
227	jsportsS01	227	t	S01
228	serskineS01	228	t	S01
229	serskineS01	229	t	S01
230	serskineS01	230	t	S01
231	jdemetriouS01	231	t	S01
232	jsportsS01	232	t	S01
233	jsportsS01	233	t	S01
234	jdemetriouS01	234	t	S01
235	jsportsS01	235	t	S01
236	serskineS01	236	t	S01
237	jsportsS01	237	t	S01
238	serskineS01	238	t	S01
239	jdemetriouS01	239	t	S01
240	jsportsS01	240	t	S01
241	serskineS01	241	t	S01
242	serskineS01	242	t	S01
243	jdemetriouS01	243	t	S01
\.


--
-- Name: staff_subscription_subscribe_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.staff_subscription_subscribe_id_seq', 243, true);


--
-- Data for Name: student; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.student (student_id, title, first_name, middle_name, last_name, po_box, address_line_one, address_line_two, city, state, postal_code, country, date_of_birth, year, is_active, medical_consideration, dietary_consideration, school_id) FROM stdin;
53	\N	Lamisa		Islam 	Chase Side	Southgate		London	Greater London	N14 5PP	UK	2009-09-09	6	t	none	CARE PLAN - allergy to nuts & eggs - can eat well cooked eat & school mayonnaise	S01
5	\N	Aaron		 James-Yarde	Chase Side	Southgate		London	Greater London	N14 5PP	UK	2010-09-22	5	t	none	none	S01
6	\N	Aaron		 Nobrega 	Chase Side	Southgate		London	Greater London	N14 5PP	UK	2011-09-13	4	t	none	none	S01
7	\N	Adam		 Nobrega 	Chase Side	Southgate		London	Greater London	N14 5PP	UK	2014-09-08	1	t	none	none	S01
8	\N	Alana 		Paul 	Chase Side	Southgate		London	Greater London	N14 5PP	UK	2012-09-11	3	t	none	none	S01
9	\N	Albert		Corici	Chase Side	Southgate		London	Greater London	N14 5PP	UK	2012-09-01	3	t	none	none	S01
10	\N	Alexander 		Erskine	Chase Side	Southgate		London	Greater London	N14 5PP	UK	2012-09-17	3	t	none	none	S01
11	\N	Amelia		Antoniou 	Chase Side	Southgate		London	Greater London	N14 5PP	UK	2009-09-07	6	t	none	none	S01
12	\N	Amelia		Williams 	Chase Side	Southgate		London	Greater London	N14 5PP	UK	2013-09-09	2	t	CARE PLAN - beware of prolonged bleeding	none	S01
13	\N	Anika		Bathuluri 	Chase Side	Southgate		London	Greater London	N14 5PP	UK	2009-09-08	6	t	none	none	S01
14	\N	Anthony 		 Chiti 	Chase Side	Southgate		London	Greater London	N14 5PP	UK	2011-09-13	4	t	Twin brothers in Reception	none	S01
15	\N	Ashish		Katta	Chase Side	Southgate		London	Greater London	N14 5PP	UK	2012-09-04	3	t	none	allergy to cod fish	S01
16	\N	Athena		Kettenis  	Chase Side	Southgate		London	Greater London	N14 5PP	UK	2011-09-12	4	t	none	none	S01
17	\N	Ava		Awoderu	Chase Side	Southgate		London	Greater London	N14 5PP	UK	2015-09-15	0	t	nonoe	none	S01
18	\N	Benjamin		Amon	Chase Side	Southgate		London	Greater London	N14 5PP	UK	2010-09-16	5	t	none	none	S01
19	\N	Carina		Awoderu	Chase Side	Southgate		London	Greater London	N14 5PP	UK	2011-09-13	4	t	none	none	S01
20	\N	Cerys		 James	Chase Side	Southgate		London	Greater London	N14 5PP	Greater London	2013-09-08	2	t	none	none	S01
21	\N	Cerys		James-Souch 	Chase Side	Southgate		London	Greater London	N14 5PP	UK	2009-09-21	6	t	none	none	S01
22	\N	Clara		Robinson	Chase Side	Southgate		London	Greater London	N14 5PP	UK	2015-09-14	0	t	Hypermobility	none	S01
23	\N	Dashon 		Joaquim	Chase Side	Southgate		London	Greater London	N14 5PP	UK	2009-09-15	6	t	none	none	S01
24	\N	Dion		Alexiou	Chase Side	Southgate		London	Greater London	N14 5PP	UK	2011-09-13	4	t	none	none	S01
25	\N	Dylan		Franklin	Chase Side	Southgate		London	Greater London	N14 5PP	UK	2011-09-15	4	t	none	none	S01
26	\N	Edward 		Trew	Chase Side	Southgate		London	Greater London	N14 5PP	UK	2009-09-08	6	t	none	none	S01
27	\N	Ektoras		Vrachoritis	Chase Side	Southgate		London	Greater London	N14 5PP	UK	2015-09-14	0	t	none	none	S01
28	\N	Elisabeth		 Brewer	Chase Side	Southgate		London	Greater London	N14 5PP	UK	2014-09-01	1	t	none	none	S01
29	\N	Eliza		Zheng	Chase Side	Southgate		London	Greater London	N14 5PP	UK	2015-09-08	0	t	none	none	S01
30	\N	Elizabeth		Avaramova 	Chase Side	Southgate		London	Greater London	N14 5PP	UK	2014-09-03	1	t	none	none	S01
31	\N	Emilia		Trew 	Chase Side	Southgate		London	Greater London	N14 5PP	UK	2014-09-27	1	t	none	none	S01
32	\N	Ethan 		Golemanov	Chase Side	Southgate		London	Greater London	N14 5PP	UK	2010-09-06	5	t	none	none	S01
33	\N	Ethan		Grobler	Chase Side	Southgate		London	Greater London	N14 5PP	UK	2013-09-16	2	t	eczema	none	S01
34	\N	Eva		Clifford	Chase Side	Southgate		London	Greater London	N14 5PP	UK	2015-09-08	0	t	none	none	S01
35	\N	Gabriella		Paschali	Chase Side	Southgate		London	Greater London	N14 5PP	UK	2014-09-02	1	t	none	none	S01
36	\N	Gabrielle		Thompson 	Chase Side	Southgate		London	Greater London	N14 5PP	UK	2014-09-02	1	t	asthma - inhaler	none	S01
37	\N	Hailey		Kan	Chase Side	Southgate		London	Greater London	N14 5PP	UK	2012-09-03	3	t	eczema	none	S01
38	\N	Herman 		Steiner	Chase Side	Southgate		London	Greater London	N14 5PP	UK	2010-09-13	5	t	none	none	S01
39	\N	Ioulios		Solomou	Chase Side	Southgate		London	Greater London	N14 5PP	UK	2015-09-08	0	t	none	none	S01
40	\N	Isaac		Clifford	Chase Side	Southgate		London	Greater London	N14 5PP	UK	2011-09-06	4	t	none	none	S01
41	\N	Isla		Willmott 	Chase Side	Southgate		London	Greater London	N14 5PP	UK	2013-09-10	2	t	asthma - inhaler	none	S01
42	\N	Isobel		Kidd 	Chase Side	Southgate		London	Greater London	N14 5PP	UK	2009-03-10	6	t	none	none	S01
43	\N	Jack		Short 	Chase Side	Southgate		London	Greater London	N14 5PP	UK	2014-09-02	1	t	none	egg allergy - can eat well cooked egg	S01
44	\N	Jacob	Gallardo	Azcona	Chase Side	Southgate		London	Greater London	N14 5PP	UK	2012-09-04	3	t	none	none	S01
45	\N	Jake 		 Nelson	Chase Side	Southgate		London	Greater London	N14 5PP	UK	2014-09-09	1	t	none	none	S01
46	\N	Javon		Coleman	Chase Side	Southgate		London	Greater London	N14 5PP	UK	2014-09-10	1	t	CARE PLAN- seizures	none	S01
47	\N	Jessica		 Kidd	Chase Side	Southgate		London	Greater London	N14 5PP	UK	2009-03-10	6	t	none	none	S01
48	\N	Johannes		Brewer	Chase Side	Southgate		London	Greater London	N14 5PP	UK	2010-09-07	5	t	none	none	S01
49	\N	Jordan		Chiti	Chase Side	Southgate		London	Greater London	N14 5PP	UK	2015-09-01	0	t	none	none	S01
50	\N	Joseph		Thompson 	Chase Side	Southgate		London	Greater London	N14 5PP	UK	2011-09-13	4	t	none	CARE PLAN - egg allergy - can eat well cooked egg & asthma	S01
51	\N	Kaleb	Gallardo	Azcona 	Chase Side	Southgate		London	Greater London	N14 5PP	UK	2012-09-12	3	t	none	none	S01
52	\N	Kanista		Wickneswaran 	Chase Side	Southgate		London	Greater London	N14 5PP	UK	2011-09-05	4	t	none	none	S01
54	\N	Leo		Chiti	Chase Side	Southgate		London	Greater London	N14 5PP	UK	2015-09-14	0	t	none	none	S01
55	\N	Leonidas		Charles	Chase Side	Southgate		London	Greater London	N14 5PP	UK	2010-09-22	5	t	allergy to penicillin	none	S01
56	\N	Leonidas		Solomou	Chase Side	Southgate		London	Greater London	N14 5P	UK	2013-09-17	2	t	none	none	S01
57	\N	Livia		Maestri	Chase Side	Southgate		London	Greater London	N14 5PP	UK	2011-09-20	4	t	none	none	S01
58	\N	Lukas		Kettenis  	Chase Side	Southgate		London	Greater London	N14 5PP	UK	2013-09-12	2	t	CARE PLAN beware of prolonged bleeding	none	S01
59	\N	Luka		Nikolaev	Chase Side	Southgate		London	Greater London	N14 5PP	UK	2013-09-09	2	t	none	none	S01
60	\N	Marco 		Sigoura 	Chase Side	Southgate		London	Greater London	N14 5PP	UK	2009-09-15	6	t	none	none	S01
61	\N	Mary		 Fernandez 	Chase Side	Southgate		London	Greater London	N5PP	UK	2009-09-15	6	t	none	none	S01
62	\N	Mia		Constantinou	Chase Side	Southgate		London	Greater London	N14 6JA	UK	2012-09-17	3	t	none	none	S01
63	\N	Mila		Toursine 	Chase Side	Southgate		London	Greater London	N14 6JA	UK	2014-09-09	1	t	none	none	S01
64	\N	Mya		James-Yarde	Chase Side	Southgate		London	Greater London	N14 6JA	UK	2011-09-15	4	t	none	none	S01
65	\N	Nadia		Naderzadeh-Turkosz	Chase Side	Southgate		London	Greater London	N14 6JA	UK	2011-09-14	4	t	none	none	S01
67	\N	Nicholas		Grobler 	Chase Side	Southgate		London	Greater London	N14 6JA	UK	2011-09-06	4	t	none	none	S01
75	\N	Samaah		Abbas	Chase Side	Southgate		London	Greater London	N14 6JA	UK	2011-09-12	4	t	none	none	S01
76	\N	Silni		Maddumage	Chase Side	Southgate		London	Greater London	N14 6JA	UK	2014-09-08	1	t	none	vegetarian	S01
77	\N	Sithmi		Maddumage	Chase Side	Southgate		London	Greater London	N14 6JA	UK	2014-09-08	1	t	none	vegetarian	S01
78	\N	Sofia		Maestri	Chase Side	Southgate		London	Greater London	N14 6JA	UK	2012-09-03	3	t	none	none	S01
79	\N	Sophia		Andreou	Chase Side	Southgate		London	Greater London	N14 6JA	UK	2014-09-08	1	t	none	none	S01
80	\N	Sophie		John-Baptiste 	Chase Side	Southgate		London	Greater London	N14 6JA	UK	2010-09-07	5	t	none	none	S01
83	\N	Tiago		Lourenco	Chase Side	Southgate		London	Greater London	N14 6JA	UK	2011-09-06	4	t	none	none	S01
84	\N	Tilda 		Warby	Chase Side	Southgate		London	Greater London	N14 6JA	UK	2009-09-08	6	t	none	none	S01
85	\N	Tommy		Newton	Chase Side	Southgate		London	Greater London	N14 6JA	UK	2014-09-09	1	t	none	none	S01
86	\N	Vedika		Bathuluri 	Chase Side	Southgate		London	Greater London	N14 6JA	UK	2013-09-18	2	t	none	none	S01
87	\N	Victor		Zheng	Chase Side	Southgate		London	Greater London	N14 6JA	UK	2012-09-04	3	t	none	none	S01
88	\N	Zaccai		Mathurin	Chase Side	Southgate		London	Greater London	N14 6JA	UK	2012-09-11	3	t	none	none	S01
89	\N	Zachary		Alexiou	Chase Side	Southgate		London	Greater London	N14 6JA	UK	2009-09-08	6	t	none	none	S01
90	\N	Zakariyah		Abbas	Chase Side	Southgate		London	Greater London	N14 6JA	UK	2014-09-08	1	t	none	none	S01
91	\N	Zac		Themistocleous	Chase Side	Southgate		London	Greater London	N14 6JA	UK	2012-09-11	3	t	none	none	S01
92	\N	Izzy		Pope	Chase Side	Southgate		London	Greater London	N14 6JA	UK	2010-09-06	5	t	none	none	S01
93	\N	Ava		Pope	Chase Side	Southgate		London	Greater London	N14 6JA	UK	2012-09-03	3	t	none	none	S01
94	\N	Abhilasha		Roy	Chase Side	Southgate		London	Greater London	N14 6JA	UK	2009-09-08	6	t	none	none	S01
95	\N	Adela		Erskine	Chase Side	Southgate		London	Greater London	N14 6JA	UK	2015-09-07	0	t	none	none	S01
96	\N	Edward		James	Chase Side	Southgate		London	Greater London	N14 6JA	UK	2015-09-11	0	t	none	none	S01
100	\N	James		Van der Beek	Address line one			london		N14 5ED	UK	2009-04-15	6	t	noone	none	S01
66	\N	Neve		Franklin	Chase Side	Southgate		London	Greater London	N14 6JA	UK	2014-09-08	1	t	none	none	S01
68	\N	Nikolas		Solomou	Chase Side	Southgate		London	Greater London	N14 6JA	UK	2015-09-01	0	t	none	none	S01
69	\N	Mason		Loucas	Chase Side	Southgate		London	Greater London	N14 6JA	UK	2015-09-09	0	t	none	none	S01
70	\N	Michael		Cristea	Chase Side	Southgate		London	Greater London	N14 6JA	UK	2015-09-09	0	t	none	none	S01
71	\N	Olivia		Udeh 	Chase Side	Southgate		London	Greater London	N14 6JA	UK	2010-09-15	5	t	hayfever	none	S01
72	\N	Riah	 Raeesa	Islam	Chase Side	Southgate		London	Greater London	N14 6JA	UK	2011-09-14	4	t	none	vegetarian	S01
73	\N	Rory	Kearney	Grant	Chase Side	Southgate		London	Greater London	N14 6JA	UK	2009-09-08	6	t	asthma - inhaler	none	S01
74	\N	Sachen		Rai-Dhesi 	Chase Side	Southgate		London	Greater London	N14 6JA	UK	2014-09-10	1	t	none	vegetarian - can eat fish & eggs	S01
81	\N	Tanishka		Wickneshwaran	Chase Side	Southgate		London	Greater London	N14 6JA	UK	2014-09-08	1	t	none	none	S01
82	\N	Thomas		Bell	Chase Side	Southgate		London	Greater London	N14 6JA	UK	2012-09-11	3	t	none	egg allergy - can eat well cooked egg	S01
101	\N	Thia		Kunaratnam	46 Kipper Road			London	Southgate	N14 5TG	UK	1999-06-23	6	t	nonE	NONE	S01
104	\N	Michael		Turner	184 Chase Side			London		N14 5RF	UK	2012-09-11	4	f	none	none	\N
107	\N	Nipuna		Perera	wts lanka ltd			Ratmalana		1010	Sri Lanka	2012-09-20	6	t			S01
108	\N	Indula		Perera	wts lanka ltd			Ratmalana		1010	Sri Lanka	2013-09-20	5	t			S01
110	\N	Adela		Erskine	12 Tha Road			London		N21 3ED	UK	2015-09-07	0	t	none	none	S01
111	\N	Alana		Paul	12 Tha Road			London		N21 3ED	UK	2012-09-03	3	t	none	none	S01
112	\N	Joseph		Thompson	12 Tha Road			London		N21 3ED	UK	2011-09-13	4	t	none	none	S01
113	\N	Isobel		Kidd	12 Tha Road			London		N21 3ED	UK	2009-09-15	6	t	none	none	S01
109	\N	Liah		Barb	12 Tha Road			London		N21 3ED	UK	2012-09-10	3	f	none	none	\N
114	\N	Jessica		Kidd	12 The Road			London		N21 3ED	UK	2009-03-10	6	t	none	none	S01
97	\N	James	Arthur 	Middleton	I am a TEST student	Palmers Green		London	Greater London	N13 4RR	UK	2009-09-16	6	f	test	test	\N
115	\N	Jessica		Jay	45 William Way			London		N21 1BL	United Kingdom	2009-03-10	6	t	none	none	S01
116	\N	Isobel		Jay	45 William Way			London		N21 1BL	United Kingdom	2009-03-10	6	t	none	none	S01
117	\N	Aaron		Nobrega 	15 Old Park Road			London		N13 4RE	United Kingdom	2011-09-22	4	t	none	none	S01
118	\N	Adam		Nobrega	15 Old Park Road			London		N13 4RE	UK	2014-09-08	1	t	none	none	S01
119	\N	sds	dsd	sd	15 Old Park Road			London		N13 4RE	United Kingdom	2019-06-02	0	f	dsd	sds	\N
120	\N	James		Anderson	15 Old Park Road			London		N13 4RE	United Kingdom	2009-08-08	6	f	None	None	\N
98	\N	Aaron		James-Yarde	Chase Side	Winchmore Hill		London	Greater London	N14 6JA	UK	2010-09-13	5	f	none	none	\N
102	\N	Adam		Williamson	95a Vicars Moor Lane			London	Greater London	N21 1BL	UK	2011-09-05	4	f	none	none	\N
103	\N	William		Wilton	95a Vicars Moor Lane			London	London	N21 1BL	UK	2009-10-15	6	f	none	none	\N
105	\N	Aaron		Nobrega 	95a Vicars Moor Lane			London		N21 1BL	UK	2011-09-13	4	f	NONE	NONE	\N
106	\N	Amelia		Williams	95a Vicars Moor Lane			London		N21 1BL	UK	2009-09-17	6	f	none	none	\N
121	\N	Amelia		Antoniou	15 Old Park Road			London		N13 4RE	United Kingdom	2009-09-15	6	t	none	none	S01
122	\N	Dashon		Joaquim	15 Old Park Road			London		N13 4RE	United Kingdom	2009-09-08	6	t	none	none	S01
123	\N	Eloise		De Jarne	15 Old Park Road			London		N13 4RE	United Kingdom	2009-09-15	6	t	none	NONE	S01
124	\N	Lucas		De Jarne	15 Old Park Road			London		N13 4RE	United Kingdom	2009-09-22	6	t	none	none	S01
125	\N	Test child		De Jarne	15 Old Park Road			London		N13 4RE	United Kingdom	2009-10-13	6	t	none	none	S01
127	\N	Cerys		James-Souch	15 Old Park Road			London		N13 4RE	United Kingdom	2009-10-13	6	t	none	none	S01
128	\N	Dashon		Joaquim	23 Old Park Road			London		N13 4QA	United Kingdom	2009-10-11	6	t	none	none	S01
129	\N	Edward		Trew	23 Old Park Road			London		N13 4QA	United Kingdom	2009-10-16	6	t	none	none	S01
130	\N	Cerys		James-Souch	23 Long Lane			London		N14 5RF	UK	2009-10-17	6	t	none	none	S01
132	\N	Adam		Nobrega	15 Old Park Road			London		N13 4RE	United Kingdom	2014-10-14	1	t	none	none	S01
133	\N	Adela		Erskine	15 Old Park Road			London		N13 4RE	United Kingdom	2015-10-13	0	t	none	none	S01
134	\N	Albert		Corici	15 Old Park Road			London		N13 4RE	United Kingdom	2012-10-03	3	t	None	None	S01
135	\N	Ethan		Grobler	15 Old Park Road			London		N13 4RE	United Kingdom	2013-10-08	2	t	none	none	S01
136	\N	Tilda	Mirjam	Warby	10 James Street			Enfield		EN1 1LF	UK	2009-02-28	6	t	n/a	No tuna	S01
140	\N	Sanath		Jayesooriya	56			Colombo		10101	Sl	2010-11-18	6	t			S01
141	\N	Jenna	James	Craven	95b Vicars Moor Lane			London		N21 1BL	UK	2009-11-17	6	t	none	none	S01
142	\N	John	James	Craven	95b Vicars Moor Lane			London		N21 1BL	UK	2010-11-20	5	t	none	none	S01
143	\N	William	John	Williams	95a Vicars Moor Lane			London		N21 1BL	UK	2009-11-25	6	t	asthma	hates vegetables	S01
99	\N	dd		dd	dd	dd	dd	dd	dd	dd	dd	2014-09-10	1	f	None	None	\N
126	\N	Sarah		TestChild	95a Vicars Moor Lane			London		N21 1BL	UK	2010-10-12	5	f	none	none	\N
131	\N	Alana		Paul	95a Vicars Moor Lane			London		N21 1BL	UK	2012-10-17	3	f	none	none	\N
137	\N	Sarah	Jane	Canterbury	95a Vicars Moor Lane			London		N21 1BL	UK	2010-11-09	5	f	allergic to bees	hates vegetables	\N
138	\N	Sarah	Jane	Winter	95a Vicars Moor Lane			London		N21 1BL	UK	2009-11-16	6	f	none	none	\N
139	\N	Kuma		Sangakkara	95a Vicars Moor Lane			London		N21 1BL	UK	2010-11-17	6	f			\N
144	\N	Isobel	Grace	Kidd	95a Vicars Moor Lane			London		N21 1BL	UK	2009-03-10	6	t	none	none	S01
145	\N	Jessica	Caitlin	Kidd	95a Vicars Moor Lane	Winchmore Hill		London		N21 1BL	United Kingdom	2009-03-10	6	t	none	none	S01
146	\N	Cerys		James-Souch	36 Oakwood Avenue			London		N14 6QL	United Kingdom	2009-12-15	6	t	none	none	S01
147	\N	Tilda		Warby	10 James Street			London		EN1 1LF	UK	2009-04-10	6	t	none	none	S01
148	\N	Ioulios		Solomou	7 Mayhew Close	Chingford		London		E4 8BB	UK	2015-03-04	0	t	None	None	S01
149	\N	Nicholas		Solomou	7 Mayhew Close	Chingford		London		E4 8BB	UK	2015-03-04	0	t	None	None	S01
150	\N	Leonidas		Solomou	7 Mayhew Close	Chingford		London		E4 8BB	UK	2013-04-03	2	t	None	None	S01
151	\N	Jane	Sarah	Wallace	95a Vicars Moor Lane	Winchmore Hill		London		N21 1BL	UK	2010-12-13	5	t	asthmatic	vegetaroam	S01
152	\N	Daisy		Saich	25 Mayfair Terrace			London		N14 6HU	United Kingdom	2010-06-07	5	t			S01
153	\N	simon		panayiotou	84 park drive			london		N21 2LS	uk	2009-12-01	6	t			S01
154	\N	Cecilia		Santoro	28 Shamrock Way			London		N14 5RY	UK	2013-07-17	2	t			S01
155	\N	Kumara		Darmasena	57			Colombo		10101	Sl	2012-12-21	5	t	None	None	S01
156	\N	Jamie		Sprakes	15 Manor Ash Road			Suffolk		IP32 5HN	United Kingdom	2009-12-15	6	t	None	None	S01
157	\N	Jayden		Sprakes	15 Manor Ash Drive			Suffolk		IP32 5HN	UK	2011-12-11	4	t	None	None	S01
158	\N	Karen		Colq	53 The Chine			London		N21 6DD	England	2009-01-03	6	t	None	None	S01
159	\N	Alexia		Iordanou	25 Merrivale			London		N14 4TE	UK	2009-09-13	5	t	None	None	S01
160	\N	Aadhavan		Kunaratnam	25 Merrivale			London		N14 4TE	UK	2015-03-11	0	t	None	None	S01
161	\N	Jane		Walker	95a Vicars Moor Lane			London		N21 1BL	UK	2009-01-14	6	t	None	None	S01
162	\N	Aadhavan		Kunaratnam	45 Southbury Avenue	Southbury Avenue		London		EN1 1RH	United Kingdom	2020-03-15	0	t	None	None	S01
163	\N	Jamie		Gelato	95a Vicars Moor Lane			London		N21 1BL	United Kingdom	2010-01-05	5	t	None	None	S01
164	\N	Murali	Muralidaran	muthtthaiya	56	Murali	Murali	Colombo		10101	Sl	2001-02-01	2	t	s	s	S01
165	\N	Chaminda	V	Vass	56			Colombo		10101	Sl	2012-02-09	6	t	None	None	S01
166	\N	Thomas	Saback	Bell	63 chase road	southgate	london	London		n14 4qy	UK	2012-07-06	3	t	None	allergic to kiwi and egg	S01
167	\N	Eva		Clifford	35 Wynchgate			London		n14 6rh	England	2009-10-01	0	t	None	None	S01
168	\N	isaac		clifford	35 Wynchgate			London		n14 6rh	England	2020-03-05	4	t	None	None	S01
\.


--
-- Data for Name: student_attendance; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.student_attendance (attendance_id, subscribe_id, student_id, attended, attendance_date, day, school_id) FROM stdin;
\.


--
-- Name: student_attendance_attendance_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.student_attendance_attendance_id_seq', 1, false);


--
-- Data for Name: student_parents; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.student_parents (student_id, parent_id, relation_id) FROM stdin;
5	StAndrewsSouthgate	5
6	StAndrewsSouthgate	6
7	StAndrewsSouthgate	7
8	StAndrewsSouthgate	8
9	StAndrewsSouthgate	9
10	StAndrewsSouthgate	10
11	StAndrewsSouthgate	11
12	StAndrewsSouthgate	12
13	StAndrewsSouthgate	13
14	StAndrewsSouthgate	14
15	StAndrewsSouthgate	15
16	StAndrewsSouthgate	16
17	StAndrewsSouthgate	17
18	StAndrewsSouthgate	18
19	StAndrewsSouthgate	19
20	StAndrewsSouthgate	20
21	StAndrewsSouthgate	21
22	StAndrewsSouthgate	22
23	StAndrewsSouthgate	23
24	StAndrewsSouthgate	24
25	StAndrewsSouthgate	25
26	StAndrewsSouthgate	26
27	StAndrewsSouthgate	27
28	StAndrewsSouthgate	28
29	StAndrewsSouthgate	29
30	StAndrewsSouthgate	30
31	StAndrewsSouthgate	31
32	StAndrewsSouthgate	32
33	StAndrewsSouthgate	33
34	StAndrewsSouthgate	34
35	StAndrewsSouthgate	35
36	StAndrewsSouthgate	36
37	StAndrewsSouthgate	37
38	StAndrewsSouthgate	38
39	StAndrewsSouthgate	39
40	StAndrewsSouthgate	40
41	StAndrewsSouthgate	41
42	StAndrewsSouthgate	42
43	StAndrewsSouthgate	43
44	StAndrewsSouthgate	44
45	StAndrewsSouthgate	45
46	StAndrewsSouthgate	46
47	StAndrewsSouthgate	47
48	StAndrewsSouthgate	48
49	StAndrewsSouthgate	49
50	StAndrewsSouthgate	50
51	StAndrewsSouthgate	51
52	StAndrewsSouthgate	52
53	StAndrewsSouthgate	53
54	StAndrewsSouthgate	54
55	StAndrewsSouthgate	55
56	StAndrewsSouthgate	56
57	StAndrewsSouthgate	57
58	StAndrewsSouthgate	58
59	StAndrewsSouthgate	59
60	StAndrewsSouthgate	60
61	StAndrewsSouthgate	61
62	StAndrewsSouthgate	62
63	StAndrewsSouthgate	63
64	StAndrewsSouthgate	64
65	StAndrewsSouthgate	65
66	StAndrewsSouthgate	66
67	StAndrewsSouthgate	67
68	StAndrewsSouthgate	68
69	StAndrewsSouthgate	69
70	StAndrewsSouthgate	70
71	StAndrewsSouthgate	71
72	StAndrewsSouthgate	72
73	StAndrewsSouthgate	73
74	StAndrewsSouthgate	74
75	StAndrewsSouthgate	75
76	StAndrewsSouthgate	76
77	StAndrewsSouthgate	77
78	StAndrewsSouthgate	78
79	StAndrewsSouthgate	79
80	StAndrewsSouthgate	80
81	StAndrewsSouthgate	81
82	StAndrewsSouthgate	82
83	StAndrewsSouthgate	83
84	StAndrewsSouthgate	84
85	StAndrewsSouthgate	85
86	StAndrewsSouthgate	86
87	StAndrewsSouthgate	87
88	StAndrewsSouthgate	88
89	StAndrewsSouthgate	89
90	StAndrewsSouthgate	90
91	StAndrewsSouthgate	91
92	StAndrewsSouthgate	92
93	StAndrewsSouthgate	93
94	StAndrewsSouthgate	94
95	StAndrewsSouthgate	95
96	StAndrewsSouthgate	96
97	SamKidd	97
98	SamKidd	98
99	SamKidd	99
100	JaneBeeks	100
101	ThiaKunaratnam	101
102	SamKidd	102
103	SamKidd	103
104	CharlotteTurner	104
105	SamKidd	105
106	SamKidd	106
107	athulaperera	107
108	athulaperera	108
109	LiahBarb	109
110	LiahBarb	110
111	LiahBarb	111
112	LiahBarb	112
113	LiahBarb	113
114	LiahBarb	114
115	PrinithJay	115
116	PrinithJay	116
117	JamieVine	117
118	JamieVine	118
119	JaneCarver	119
120	JaneCarver	120
121	JaneCarver	121
122	JaneCarver	122
123	SuzanneDeJarne	123
124	SuzanneDeJarne	124
125	SuzanneDeJarne	125
126	SamKidd	126
127	SuzanneDeJarne	127
128	SuzanneDeJarne	128
129	SuzanneDeJarne	129
130	Ruth-JamesSouch	130
131	SamKidd	131
132	SuzanneDeJarne	132
133	SuzanneDeJarne	133
134	SuzanneDeJarne	134
135	SuzanneDeJarne	135
136	mariwarby	136
137	SamKidd	137
138	SamKidd	138
139	SamKidd	139
140	mahelaj	140
141	Parent3V4	141
142	Parent3V4	142
143	Parent4V4	143
144	SamKidd	144
145	SamKidd	145
146	RuthJamesSouch4	146
147	MariWarby	147
148	MrsSolomou	148
149	MrsSolomou	149
150	MrsSolomou	150
151	WilliamWallace	151
152	KirstyS	152
153	andipandy	153
154	PSantoro	154
155	mahelaj	155
156	StephAdam	156
157	StephAdam	157
158	scolq	158
159	Maro122	159
160	Maro122	160
161	SamKidd	161
163	KennyG	163
164	mahelaj	164
165	mahelaj	165
166	SamKidd	166
167	OClifford	167
168	OClifford	168
\.


--
-- Name: student_parents_relation_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.student_parents_relation_id_seq', 168, true);


--
-- Name: student_student_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.student_student_id_seq', 168, true);


--
-- Data for Name: student_subscription; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.student_subscription (subscribe_id, event_id, student_id, year, subscrib_on, term_id, approved, combine_tier_id, reference_id, school_id) FROM stdin;
1098	155	101	6	2020-03-03 00:00:00	3	t	5	0332020100456	S01
1097	241	101	6	2020-03-03 00:00:00	3	t	5	0332020100456	S01
1096	242	101	6	2020-03-03 00:00:00	3	t	5	0332020100456	S01
1095	243	101	6	2020-03-03 00:00:00	3	t	5	0332020100456	S01
1094	147	101	6	2020-03-03 00:00:00	3	t	5	0332020100456	S01
1100	225	166	3	2020-03-04 00:00:00	3	t	1	0432020094900	S01
1099	136	166	3	2020-03-04 00:00:00	3	t	1	0432020094900	S01
1103	196	167	0	2020-03-05 00:00:00	2	t	5	0532020094329	S01
1102	192	167	0	2020-03-05 00:00:00	2	t	5	0532020094329	S01
1101	211	167	0	2020-03-05 00:00:00	2	t	7	0532020094329	S01
1109	235	168	4	2020-03-05 00:00:00	3	t	7	0532020094615	S01
1108	142	168	4	2020-03-05 00:00:00	3	t	2	0532020094615	S01
1107	233	168	4	2020-03-05 00:00:00	3	t	7	0532020094615	S01
1106	140	168	4	2020-03-05 00:00:00	3	t	2	0532020094615	S01
1105	231	168	4	2020-03-05 00:00:00	3	t	7	0532020094615	S01
1104	134	168	4	2020-03-05 00:00:00	3	t	1	0532020094615	S01
1110	191	168	4	2020-03-05 00:00:00	2	f	5	0532020100720	S01
1111	192	168	4	2020-03-05 00:00:00	2	f	5	0532020100720	S01
1112	196	168	4	2020-03-05 00:00:00	2	f	5	0532020100720	S01
\.


--
-- Name: student_subscription_subscribe_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.student_subscription_subscribe_id_seq', 1112, true);


--
-- Data for Name: subscribe_transaction; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.subscribe_transaction (payment_id, subscribe_id, parent_id, student_id, combine_id, term_id, amount, approved_date, invoice_id, day_count, school_id) FROM stdin;
1053	1104	OClifford	168	1	3	20.00	2020-03-05 09:50:41.959891	2020030004	10	S01
1052	1105	OClifford	168	7	3	88.00	2020-03-05 09:50:41.950183	2020030004	10	S01
1051	1106	OClifford	168	2	3	36.00	2020-03-05 09:50:41.937081	2020030004	12	S01
1050	1107	OClifford	168	7	3	105.60	2020-03-05 09:50:41.918193	2020030004	12	S01
1049	1108	OClifford	168	2	3	36.00	2020-03-05 09:50:41.906149	2020030004	12	S01
1048	1109	OClifford	168	7	3	105.60	2020-03-05 09:50:41.888309	2020030004	12	S01
1042	1094	ThiaKunaratnam	101	5	3	30.00	2020-03-03 10:08:22.761428	2020030001	10	S01
1041	1095	ThiaKunaratnam	101	5	3	36.00	2020-03-03 10:08:22.75456	2020030001	12	S01
1040	1096	ThiaKunaratnam	101	5	3	36.00	2020-03-03 10:08:22.747108	2020030001	12	S01
1039	1097	ThiaKunaratnam	101	5	3	36.00	2020-03-03 10:08:22.740669	2020030001	12	S01
1038	1098	ThiaKunaratnam	101	5	3	33.00	2020-03-03 10:08:22.720405	2020030001	11	S01
1044	1099	SamKidd	166	1	3	24.00	2020-03-04 09:51:26.982166	2020030002	12	S01
1043	1100	SamKidd	166	1	3	60.00	2020-03-04 09:51:26.954692	2020030002	12	S01
1047	1101	OClifford	167	7	2	35.20	2020-03-05 09:48:17.628191	2020030003	4	S01
1046	1102	OClifford	167	5	2	12.00	2020-03-05 09:48:17.616142	2020030003	4	S01
1045	1103	OClifford	167	5	2	15.00	2020-03-05 09:48:17.590462	2020030003	5	S01
\.


--
-- Name: subscribe_transaction_payment_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.subscribe_transaction_payment_id_seq', 1053, true);


--
-- Data for Name: term; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.term (term_id, term_name, start_date, end_date, monday_count, tuesday_count, wednesday_count, thursday_count, friday_count, year_id, school_id, is_deleted, holiday) FROM stdin;
2	Spring Term (2019/20)	2020-01-06	2020-04-03	11	12	12	12	12	1	S01	f	06/01/2020, 17/02/2020, 18/02/2020, 19/02/2020, 20/02/2020, 21/02/2020
3	Summer Term (2019/20)	2020-04-20	2020-07-20	10	12	12	12	12	1	S01	f	20/04/2020, 04/05/2020, 25/05/2020, 26/05/2020, 27/05/2020, 28/05/2020, 29/05/2020, 20/07/2020
\.


--
-- Name: term_term_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.term_term_id_seq', 3, true);


--
-- Data for Name: tier; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tier (tier_id, name, start_time, end_time, price, note, main, associate_tier_id, day, school_id, term_id, is_active, year_id) FROM stdin;
3	AFTERNOON****	16:30	18:00	5.80	\N	\N	\N	\N	S01	0	f	1
6	Supper	16:30	17:00	2.80	\N	\N	\N	\N	S01	0	f	1
8	Tier 05	15:30	16:30	3.00	\N	\N	\N	\N	S01	0	f	1
9	Tier 03	16:30	18:00	5.80	\N	\N	\N	\N	S01	0	f	1
4	Tier 5: Evening Club from 16:30 to 18:00	16:30	18:00	5.80	\N	\N	\N	\N	S01	0	f	1
1	Tier 1 :  Morning Club  + Breakfast	07:30	08:45	5.00	\N	\N	\N	\N	S01	0	t	1
2	Tier 2 : Morning Club only	08:00	08:45	3.00	\N	\N	\N	\N	S01	0	t	1
7	Tier 3: Afternoon Club + Supper	15:30	18:00	8.80	\N	\N	\N	\N	S01	0	t	1
5	Tier 4: Afternoon Club only	15:30	16:30	3.00	\N	\N	\N	\N	S01	0	t	1
\.


--
-- Data for Name: tier_combine_term; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tier_combine_term (combine_tier_id, tier_id, main, associate_id, term_id, is_active, note) FROM stdin;
77	1	t	\N	3	f	
16	3	t	\N	2	f	undefined
24	3	t	\N	1	f	
25	4	f	3	1	f	
26	5	f	3	1	f	
17	4	f	3	2	f	undefined
27	6	f	3	1	f	
18	5	f	3	2	f	undefined
30	3	t	\N	2	f	
28	3	t	\N	1	f	
32	3	t	\N	3	f	
31	4	f	3	2	f	
19	6	f	3	2	f	undefined
29	4	f	3	1	f	
33	4	f	3	3	f	
73	1	t	\N	1	f	
75	1	t	\N	2	f	
78	2	f	1	3	f	
74	2	f	1	1	f	
76	2	f	1	2	f	
20	3	t	\N	3	f	
21	4	f	3	3	f	
10	3	t	\N	2	f	undefined
7	3	t	\N	1	f	undefined
13	3	t	\N	3	f	undefined
11	4	f	3	2	f	undefined
14	4	f	3	3	f	undefined
8	4	f	3	1	f	undefined
15	5	f	3	3	f	undefined
12	5	f	3	2	f	undefined
9	5	f	3	1	f	undefined
22	5	f	3	3	f	
23	6	f	3	3	f	
103	3	t	\N	3	f	undefined
97	3	t	\N	1	f	undefined
100	3	t	\N	2	f	undefined
82	4	f	7	2	f	
80	4	f	7	1	f	
46	3	t	\N	1	f	undefined
49	3	t	\N	2	f	undefined
52	3	t	\N	3	f	undefined
43	4	f	7	2	f	undefined
41	4	f	7	1	f	undefined
45	4	f	7	3	f	undefined
47	5	f	3	1	f	undefined
36	5	t	\N	2	f	undefined
38	5	t	\N	3	f	undefined
34	5	t	\N	1	f	undefined
37	6	f	5	2	f	undefined
35	6	f	5	1	f	undefined
39	6	f	5	3	f	undefined
84	4	f	7	3	f	
3	1	t	\N	2	f	
1	1	t	\N	1	f	
5	1	t	\N	3	f	
2	2	f	1	1	f	
6	2	f	1	3	f	
4	2	f	1	2	f	
67	3	t	\N	1	f	undefined
69	3	t	\N	2	f	undefined
71	3	t	\N	3	f	undefined
58	4	f	7	2	f	
60	4	f	7	3	f	
53	5	f	3	3	f	undefined
50	5	f	3	2	f	undefined
54	6	f	3	3	f	undefined
48	6	f	3	1	f	undefined
51	6	f	3	2	f	undefined
44	7	t	\N	3	f	undefined
42	7	t	\N	2	f	undefined
40	7	t	\N	1	f	undefined
91	3	t	\N	1	f	undefined
61	3	t	\N	1	f	undefined
63	3	t	\N	2	f	undefined
65	3	t	\N	3	f	undefined
93	3	t	\N	2	f	undefined
95	3	t	\N	3	f	undefined
64	5	f	3	2	f	undefined
62	5	f	3	1	f	undefined
66	5	f	3	3	f	undefined
56	4	f	7	1	f	
68	5	f	3	1	f	undefined
72	5	f	3	3	f	undefined
70	5	f	3	2	f	undefined
57	7	t	\N	2	f	
55	7	t	\N	1	f	
59	7	t	\N	3	f	
85	3	t	\N	1	f	undefined
89	3	t	\N	3	f	undefined
87	3	t	\N	2	f	undefined
94	5	f	3	2	f	undefined
92	5	f	3	1	f	undefined
96	5	f	3	3	f	undefined
86	5	f	3	1	f	undefined
88	5	f	3	2	f	undefined
90	5	f	3	3	f	undefined
113	4	f	7	1	f	
115	4	f	7	2	f	
114	7	t	\N	2	f	
112	7	t	\N	1	f	
104	5	f	3	3	f	undefined
101	5	f	3	2	f	undefined
98	5	f	3	1	f	undefined
105	6	f	3	3	f	undefined
99	6	f	3	1	f	undefined
102	6	f	3	2	f	undefined
79	7	t	\N	1	f	
81	7	t	\N	2	f	
83	7	t	\N	3	f	
121	3	t	\N	2	f	undefined
124	3	t	\N	3	f	undefined
118	3	t	\N	1	f	undefined
151	3	t	\N	1	f	undefined
119	5	f	3	1	f	undefined
122	5	f	3	2	f	undefined
125	5	f	3	3	f	undefined
126	6	f	3	3	f	undefined
120	6	f	3	1	f	undefined
123	6	f	3	2	f	undefined
157	3	t	\N	3	f	undefined
154	3	t	\N	2	f	undefined
131	3	t	\N	3	f	undefined
127	3	t	\N	1	f	undefined
129	3	t	\N	2	f	undefined
117	4	f	7	3	f	
128	5	f	3	1	f	undefined
130	5	f	3	2	f	undefined
132	5	f	3	3	f	undefined
116	7	t	\N	3	f	
158	6	f	3	3	f	undefined
152	6	f	3	1	f	undefined
155	6	f	3	2	f	undefined
159	7	f	3	3	f	undefined
153	7	f	3	1	f	undefined
156	7	f	3	2	f	undefined
145	3	t	\N	1	f	undefined
149	3	t	\N	3	f	undefined
147	3	t	\N	2	f	undefined
146	6	f	3	1	f	undefined
148	6	f	3	2	f	undefined
150	6	f	3	3	f	undefined
133	4	t	\N	1	f	
135	4	t	\N	2	f	
137	4	t	\N	3	f	
143	5	t	\N	3	f	
141	5	t	\N	2	f	
139	5	t	\N	1	f	
136	8	f	4	2	f	
134	8	f	4	1	f	
138	8	f	4	3	f	
142	9	f	5	2	f	
140	9	f	5	1	f	
144	9	f	5	3	f	
161	4	f	7	1	f	undefined
164	4	f	7	2	f	undefined
167	4	f	7	3	f	undefined
168	5	f	7	3	f	undefined
165	5	f	7	2	f	undefined
162	5	f	7	1	f	undefined
163	7	t	\N	2	f	undefined
166	7	t	\N	3	f	undefined
160	7	t	\N	1	f	undefined
174	4	f	7	3	f	undefined
170	4	f	7	1	f	undefined
172	4	f	7	2	f	undefined
177	5	f	7	3	f	undefined
175	5	f	7	1	f	undefined
176	5	f	7	2	f	undefined
169	7	t	\N	1	f	undefined
173	7	t	\N	3	f	undefined
171	7	t	\N	2	f	undefined
108	1	t	\N	2	f	
106	1	t	\N	1	f	
107	2	f	1	1	f	
109	2	f	1	2	f	
111	2	f	1	3	f	
181	5	f	7	2	f	
179	5	f	7	3	f	
180	7	t	\N	2	f	
178	7	t	\N	3	f	
186	1	t	\N	2	t	undefined
187	2	f	1	2	t	undefined
188	2	f	1	3	t	undefined
182	7	t	\N	3	t	
183	5	f	7	3	t	
184	7	t	\N	2	t	
185	5	f	7	2	t	
110	1	t	\N	3	t	
\.


--
-- Name: tier_combine_term_combine_tier_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tier_combine_term_combine_tier_id_seq', 188, true);


--
-- Name: tier_tier_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tier_tier_id_seq', 9, true);


--
-- Data for Name: year; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.year (year_id, year_name, school_id, description, from_date, to_date, is_active, year_road) FROM stdin;
1	2019-20	S01	2019 to 2020	2019-09-02	2020-07-20	t	\N
2	2	S01	2019-20 (New)	2019-09-02	2020-07-20	f	\N
\.


--
-- Name: year_year_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.year_year_id_seq', 2, true);


--
-- Name: activity activity_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.activity
    ADD CONSTRAINT activity_pkey PRIMARY KEY (activity_id);


--
-- Name: event event_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.event
    ADD CONSTRAINT event_pkey PRIMARY KEY (event_id);


--
-- Name: fee fee_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.fee
    ADD CONSTRAINT fee_pkey PRIMARY KEY (fee_id);


--
-- Name: invoice invoice_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT invoice_pkey PRIMARY KEY (invoice_id);


--
-- Name: invoice_receipt invoice_receipt_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.invoice_receipt
    ADD CONSTRAINT invoice_receipt_pkey PRIMARY KEY (transaction_id);


--
-- Name: parent parent_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.parent
    ADD CONSTRAINT parent_pkey PRIMARY KEY (parent_id);


--
-- Name: school school_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.school
    ADD CONSTRAINT school_pkey PRIMARY KEY (school_id);


--
-- Name: staff staff_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.staff
    ADD CONSTRAINT staff_pkey PRIMARY KEY (staff_id);


--
-- Name: staff_subscription staff_subscription_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.staff_subscription
    ADD CONSTRAINT staff_subscription_pkey PRIMARY KEY (subscribe_id);


--
-- Name: student_attendance student_attendance_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.student_attendance
    ADD CONSTRAINT student_attendance_pkey PRIMARY KEY (attendance_id);


--
-- Name: student_parents student_parents_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.student_parents
    ADD CONSTRAINT student_parents_pkey PRIMARY KEY (relation_id);


--
-- Name: student student_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.student
    ADD CONSTRAINT student_pkey PRIMARY KEY (student_id);


--
-- Name: student_subscription student_subscription_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.student_subscription
    ADD CONSTRAINT student_subscription_pkey PRIMARY KEY (subscribe_id);


--
-- Name: subscribe_transaction subscribe_transaction_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.subscribe_transaction
    ADD CONSTRAINT subscribe_transaction_pkey PRIMARY KEY (payment_id);


--
-- Name: term term_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.term
    ADD CONSTRAINT term_pkey PRIMARY KEY (term_id);


--
-- Name: tier_combine_term tier_combine_term_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tier_combine_term
    ADD CONSTRAINT tier_combine_term_pkey PRIMARY KEY (combine_tier_id);


--
-- Name: tier tier_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tier
    ADD CONSTRAINT tier_pkey PRIMARY KEY (tier_id);


--
-- Name: receipt transaction_receipt_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.receipt
    ADD CONSTRAINT transaction_receipt_pkey PRIMARY KEY (receipt_id);


--
-- Name: year year_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.year
    ADD CONSTRAINT year_pkey PRIMARY KEY (year_id);


--
-- Name: get_avalibale_clubs _RETURN; Type: RULE; Schema: public; Owner: postgres
--

CREATE OR REPLACE VIEW public.get_avalibale_clubs AS
 SELECT row_number() OVER (PARTITION BY true::boolean) AS row_number,
    count(student_subscription.student_id) AS studentcount,
    event.activity_id,
    term.term_id,
    event.day,
    activity.space,
    (activity.space - count(student_subscription.student_id)) AS availablespace,
        CASE
            WHEN (count(student_subscription.student_id) <= activity.space) THEN 'true'::text
            ELSE 'false'::text
        END AS status
   FROM (((public.student_subscription
     JOIN public.event ON ((student_subscription.event_id = event.event_id)))
     JOIN public.activity ON ((activity.activity_id = event.activity_id)))
     JOIN public.term ON ((student_subscription.term_id = term.term_id)))
  WHERE (student_subscription.approved = true)
  GROUP BY event.activity_id, event.day, activity.activity_id, term.term_id;


--
-- Name: payments_outstanding_view _RETURN; Type: RULE; Schema: public; Owner: postgres
--

CREATE OR REPLACE VIEW public.payments_outstanding_view AS
 SELECT row_number() OVER (PARTITION BY true::boolean) AS row_number,
    p.parent_id,
    concat_ws(' '::text, NULLIF(btrim((p.first_name)::text), ''::text), NULLIF(btrim((p.middle_name)::text), ''::text), NULLIF(btrim((p.last_name)::text), ''::text)) AS parentname,
    s.student_id,
    concat_ws(' '::text, NULLIF(btrim((s.first_name)::text), ''::text), NULLIF(btrim((s.middle_name)::text), ''::text), NULLIF(btrim((s.last_name)::text), ''::text)) AS childname,
    sum(
        CASE
            WHEN ((e.day)::text = 'Monday'::text) THEN ((te.monday_count)::numeric * (t.price - subtrans.amount))
            WHEN ((e.day)::text = 'Tuesday'::text) THEN ((te.tuesday_count)::numeric * (t.price - subtrans.amount))
            WHEN ((e.day)::text = 'Wednesday'::text) THEN ((te.wednesday_count)::numeric * (t.price - subtrans.amount))
            WHEN ((e.day)::text = 'Thursday'::text) THEN ((te.thursday_count)::numeric * (t.price - subtrans.amount))
            WHEN ((e.day)::text = 'Friday'::text) THEN ((te.friday_count)::numeric * (t.price - subtrans.amount))
            WHEN (e.day IS NULL) THEN ((((((te.monday_count + te.tuesday_count) + te.wednesday_count) + te.thursday_count) + te.friday_count))::numeric * (t.price - subtrans.amount))
            ELSE (NULL::integer)::numeric
        END) AS amountoutstanding,
    te.term_id,
    te.term_name AS termname,
    date_part('year'::text, te.start_date) AS year
   FROM (((((((((((public.student_subscription a
     JOIN public.student s ON ((a.student_id = s.student_id)))
     JOIN public.student_parents sp ON ((s.student_id = sp.student_id)))
     JOIN public.parent p ON (((sp.parent_id)::text = (p.parent_id)::text)))
     JOIN public.event e ON ((a.event_id = e.event_id)))
     JOIN public.tier t ON ((t.tier_id = e.tier_id)))
     JOIN public.activity ac ON ((ac.activity_id = e.activity_id)))
     JOIN public.term te ON ((a.term_id = te.term_id)))
     JOIN public.receipt rec ON ((s.student_id = rec.student_id)))
     JOIN public.invoice inv ON ((s.student_id = inv.student_id)))
     JOIN public.invoice_receipt invrec ON (((inv.invoice_id = invrec.invoice_id) AND (rec.receipt_id = invrec.invoice_id))))
     JOIN public.subscribe_transaction subtrans ON (((subtrans.subscribe_id = invrec.invoice_id) AND (subtrans.student_id = a.student_id))))
  WHERE ((t.price - subtrans.amount) > (0)::numeric)
  GROUP BY p.parent_id, (concat_ws(' '::text, NULLIF(btrim((p.first_name)::text), ''::text), NULLIF(btrim((p.middle_name)::text), ''::text), NULLIF(btrim((p.last_name)::text), ''::text))), s.student_id, (concat_ws(' '::text, NULLIF(btrim((s.first_name)::text), ''::text), NULLIF(btrim((s.middle_name)::text), ''::text), NULLIF(btrim((s.last_name)::text), ''::text))), e.day, te.term_id, te.term_name
  ORDER BY p.parent_id, s.student_id;


--
-- Name: report_parent_invoice _RETURN; Type: RULE; Schema: public; Owner: postgres
--

CREATE OR REPLACE VIEW public.report_parent_invoice AS
 SELECT row_number() OVER (PARTITION BY true::boolean) AS row_number,
    a.school_id,
    p.parent_id,
    concat_ws(' '::text, NULLIF(btrim((p.first_name)::text), ''::text), NULLIF(btrim((p.middle_name)::text), ''::text), NULLIF(btrim((p.last_name)::text), ''::text)) AS parent_name,
    s.student_id,
    concat_ws(' '::text, NULLIF(btrim((s.first_name)::text), ''::text), NULLIF(btrim((s.middle_name)::text), ''::text), NULLIF(btrim((s.last_name)::text), ''::text)) AS student_name,
    COALESCE(sum(a.amount), (0)::numeric) AS full_amount
   FROM (((public.invoice a
     JOIN public.student s ON ((a.student_id = s.student_id)))
     JOIN public.student_parents sp ON ((s.student_id = sp.student_id)))
     JOIN public.parent p ON (((sp.parent_id)::text = (p.parent_id)::text)))
  GROUP BY a.school_id, p.parent_id, s.student_id
  ORDER BY a.school_id;


--
-- Name: report_parent_receipt _RETURN; Type: RULE; Schema: public; Owner: postgres
--

CREATE OR REPLACE VIEW public.report_parent_receipt AS
 SELECT row_number() OVER (PARTITION BY true::boolean) AS row_number,
    a.school_id,
    p.parent_id,
    concat_ws(' '::text, NULLIF(btrim((p.first_name)::text), ''::text), NULLIF(btrim((p.middle_name)::text), ''::text), NULLIF(btrim((p.last_name)::text), ''::text)) AS parent_name,
    s.student_id,
    concat_ws(' '::text, NULLIF(btrim((s.first_name)::text), ''::text), NULLIF(btrim((s.middle_name)::text), ''::text), NULLIF(btrim((s.last_name)::text), ''::text)) AS student_name,
    COALESCE(sum(a.amount), (0)::numeric) AS full_amount
   FROM (((public.receipt a
     JOIN public.student s ON ((a.student_id = s.student_id)))
     JOIN public.student_parents sp ON ((s.student_id = sp.student_id)))
     JOIN public.parent p ON (((sp.parent_id)::text = (p.parent_id)::text)))
  GROUP BY a.school_id, p.parent_id, s.student_id
  ORDER BY a.school_id;


--
-- Name: get_all_invocies _RETURN; Type: RULE; Schema: public; Owner: postgres
--

CREATE OR REPLACE VIEW public.get_all_invocies AS
 SELECT row_number() OVER (PARTITION BY true::boolean) AS row_number,
    parent.parent_id AS parentid,
    concat_ws(' '::text, NULLIF(btrim((parent.first_name)::text), ''::text), NULLIF(btrim((parent.middle_name)::text), ''::text), NULLIF(btrim((parent.last_name)::text), ''::text)) AS parentname,
    parent.email AS parentemail,
    parent.relationship AS parentrelation,
    parent.phone_no AS parentphoneno,
    student.student_id AS studentid,
    concat_ws(' '::text, NULLIF(btrim((student.first_name)::text), ''::text), NULLIF(btrim((student.middle_name)::text), ''::text), NULLIF(btrim((student.last_name)::text), ''::text)) AS studentname,
    student.year AS studentyear,
    invoice.invoice_id AS invoiceid,
    invoice.invoice_no AS invoiceno,
    invoice.invoice_date AS invoicedate,
    invoice.amount AS invoiceamount,
    (invoice.amount - COALESCE(sum(receipt.amount), (0)::numeric)) AS totalbalance,
    invoice.description AS invoicedescription,
    invoice.school_id AS schoolid
   FROM (((((public.invoice
     JOIN public.student_parents ON ((student_parents.student_id = invoice.student_id)))
     JOIN public.student ON ((student_parents.student_id = student.student_id)))
     JOIN public.parent ON (((student_parents.parent_id)::text = (parent.parent_id)::text)))
     LEFT JOIN public.invoice_receipt ON ((invoice_receipt.invoice_id = invoice.invoice_id)))
     LEFT JOIN public.receipt ON ((invoice_receipt.receipt_id = receipt.receipt_id)))
  GROUP BY invoice.invoice_id, parent.parent_id, student.student_id
 HAVING ((invoice.amount - COALESCE(sum(receipt.amount), (0)::numeric)) > (0)::numeric);


--
-- Name: activity activity_school_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.activity
    ADD CONSTRAINT activity_school_id_fkey FOREIGN KEY (school_id) REFERENCES public.school(school_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: event event_activity_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.event
    ADD CONSTRAINT event_activity_id_fkey FOREIGN KEY (activity_id) REFERENCES public.activity(activity_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: event event_school_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.event
    ADD CONSTRAINT event_school_id_fkey FOREIGN KEY (school_id) REFERENCES public.school(school_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: event event_term_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.event
    ADD CONSTRAINT event_term_id_fkey FOREIGN KEY (term_id) REFERENCES public.term(term_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: event event_tier_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.event
    ADD CONSTRAINT event_tier_id_fkey FOREIGN KEY (tier_id) REFERENCES public.tier(tier_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: event event_year_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.event
    ADD CONSTRAINT event_year_id_fkey FOREIGN KEY (year_id) REFERENCES public.year(year_id);


--
-- Name: fee fee_activity_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.fee
    ADD CONSTRAINT fee_activity_id_fkey FOREIGN KEY (activity_id) REFERENCES public.activity(activity_id) ON UPDATE CASCADE;


--
-- Name: fee fee_school_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.fee
    ADD CONSTRAINT fee_school_id_fkey FOREIGN KEY (school_id) REFERENCES public.school(school_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fee fee_tier_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.fee
    ADD CONSTRAINT fee_tier_id_fkey FOREIGN KEY (tier_id) REFERENCES public.tier(tier_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: invoice invoice_parent_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT invoice_parent_id_fkey FOREIGN KEY (parent_id) REFERENCES public.parent(parent_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: invoice_receipt invoice_receipt_invoice_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.invoice_receipt
    ADD CONSTRAINT invoice_receipt_invoice_id_fkey FOREIGN KEY (invoice_id) REFERENCES public.invoice(invoice_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: invoice invoice_school_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT invoice_school_id_fkey FOREIGN KEY (school_id) REFERENCES public.school(school_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: invoice invoice_student_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.invoice
    ADD CONSTRAINT invoice_student_id_fkey FOREIGN KEY (student_id) REFERENCES public.student(student_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: parent parent_school_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.parent
    ADD CONSTRAINT parent_school_id_fkey FOREIGN KEY (school_id) REFERENCES public.school(school_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: receipt receipt_parent_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.receipt
    ADD CONSTRAINT receipt_parent_id_fkey FOREIGN KEY (parent_id) REFERENCES public.parent(parent_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: receipt receipt_school_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.receipt
    ADD CONSTRAINT receipt_school_id_fkey FOREIGN KEY (school_id) REFERENCES public.school(school_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: receipt receipt_student_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.receipt
    ADD CONSTRAINT receipt_student_id_fkey FOREIGN KEY (student_id) REFERENCES public.student(student_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: staff staff_school_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.staff
    ADD CONSTRAINT staff_school_id_fkey FOREIGN KEY (school_id) REFERENCES public.school(school_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: staff_subscription staff_subscription_event_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.staff_subscription
    ADD CONSTRAINT staff_subscription_event_id_fkey FOREIGN KEY (event_id) REFERENCES public.event(event_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: staff_subscription staff_subscription_school_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.staff_subscription
    ADD CONSTRAINT staff_subscription_school_id_fkey FOREIGN KEY (school_id) REFERENCES public.school(school_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: staff_subscription staff_subscription_staff_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.staff_subscription
    ADD CONSTRAINT staff_subscription_staff_id_fkey FOREIGN KEY (staff_id) REFERENCES public.staff(staff_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: student_attendance student_attendance_school_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.student_attendance
    ADD CONSTRAINT student_attendance_school_id_fkey FOREIGN KEY (school_id) REFERENCES public.school(school_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: student_attendance student_attendance_subscribe_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.student_attendance
    ADD CONSTRAINT student_attendance_subscribe_id_fkey FOREIGN KEY (subscribe_id) REFERENCES public.student_subscription(subscribe_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: student_parents student_parents_parent_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.student_parents
    ADD CONSTRAINT student_parents_parent_id_fkey FOREIGN KEY (parent_id) REFERENCES public.parent(parent_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: student_parents student_parents_student_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.student_parents
    ADD CONSTRAINT student_parents_student_id_fkey FOREIGN KEY (student_id) REFERENCES public.student(student_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: student student_school_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.student
    ADD CONSTRAINT student_school_id_fkey FOREIGN KEY (school_id) REFERENCES public.school(school_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: term term_school_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.term
    ADD CONSTRAINT term_school_id_fkey FOREIGN KEY (school_id) REFERENCES public.school(school_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: term term_year_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.term
    ADD CONSTRAINT term_year_id_fkey FOREIGN KEY (year_id) REFERENCES public.year(year_id);


--
-- Name: tier tier_associate_term_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tier
    ADD CONSTRAINT tier_associate_term_id_fkey FOREIGN KEY (associate_tier_id) REFERENCES public.tier(tier_id);


--
-- Name: tier tier_school_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tier
    ADD CONSTRAINT tier_school_id_fkey FOREIGN KEY (school_id) REFERENCES public.school(school_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: tier tier_year_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tier
    ADD CONSTRAINT tier_year_id_fkey FOREIGN KEY (year_id) REFERENCES public.year(year_id);


--
-- Name: year year_school_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.year
    ADD CONSTRAINT year_school_id_fkey FOREIGN KEY (school_id) REFERENCES public.school(school_id);


--
-- PostgreSQL database dump complete
--

