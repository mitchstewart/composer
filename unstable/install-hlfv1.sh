ME=`basename "$0"`
if [ "${ME}" = "install-hlfv1.sh" ]; then
  echo "Please re-run as >   cat install-hlfv1.sh | bash"
  exit 1
fi
(cat > composer.sh; chmod +x composer.sh; exec bash composer.sh)
#!/bin/bash
set -e

# Docker stop function
function stop()
{
P1=$(docker ps -q)
if [ "${P1}" != "" ]; then
  echo "Killing all running containers"  &2> /dev/null
  docker kill ${P1}
fi

P2=$(docker ps -aq)
if [ "${P2}" != "" ]; then
  echo "Removing all containers"  &2> /dev/null
  docker rm ${P2} -f
fi
}

if [ "$1" == "stop" ]; then
 echo "Stopping all Docker containers" >&2
 stop
 exit 0
fi

# Get the current directory.
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Get the full path to this script.
SOURCE="${DIR}/composer.sh"

# Create a work directory for extracting files into.
WORKDIR="$(pwd)/composer-data"
rm -rf "${WORKDIR}" && mkdir -p "${WORKDIR}"
cd "${WORKDIR}"

# Find the PAYLOAD: marker in this script.
PAYLOAD_LINE=$(grep -a -n '^PAYLOAD:$' "${SOURCE}" | cut -d ':' -f 1)
echo PAYLOAD_LINE=${PAYLOAD_LINE}

# Find and extract the payload in this script.
PAYLOAD_START=$((PAYLOAD_LINE + 1))
echo PAYLOAD_START=${PAYLOAD_START}
tail -n +${PAYLOAD_START} "${SOURCE}" | tar -xzf -

# stop all the docker containers
stop



# run the fabric-dev-scripts to get a running fabric
./fabric-dev-servers/downloadFabric.sh
./fabric-dev-servers/startFabric.sh
./fabric-dev-servers/createComposerProfile.sh

# Start all composer
docker-compose -p composer -f docker-compose-playground.yml up -d
# copy over pre-imported admin credentials
cd fabric-dev-servers/fabric-scripts/hlfv1/composer/creds
docker exec composer mkdir /home/composer/.hfc-key-store
tar -cv * | docker exec -i composer tar x -C /home/composer/.hfc-key-store

# Wait for playground to start
sleep 5

# Kill and remove any running Docker containers.
##docker-compose -p composer kill
##docker-compose -p composer down --remove-orphans

# Kill any other Docker containers.
##docker ps -aq | xargs docker rm -f

# Open the playground in a web browser.
case "$(uname)" in
"Darwin") open http://localhost:8080
          ;;
"Linux")  if [ -n "$BROWSER" ] ; then
	       	        $BROWSER http://localhost:8080
	        elif    which xdg-open > /dev/null ; then
	                xdg-open http://localhost:8080
          elif  	which gnome-open > /dev/null ; then
	                gnome-open http://localhost:8080
          #elif other types blah blah
	        else
    	            echo "Could not detect web browser to use - please launch Composer Playground URL using your chosen browser ie: <browser executable name> http://localhost:8080 or set your BROWSER variable to the browser launcher in your PATH"
	        fi
          ;;
*)        echo "Playground not launched - this OS is currently not supported "
          ;;
esac

echo
echo "--------------------------------------------------------------------------------------"
echo "Hyperledger Fabric and Hyperledger Composer installed, and Composer Playground launched"
echo "Please use 'composer.sh' to re-start"

# removing instalation image
rm "${DIR}"/install-hlfv1.sh

# Exit; this is required as the payload immediately follows.
exit 0
PAYLOAD:
� ��BY �=M��Hv��dw���A'@�9����������IQ����4��*I�(RMR�Ԇ�9$��K~A.An{\9�Kr�=�C.9� �")�>[�a�=c=ÖT����{�^�WU,��͠bt{��=M5M���C����� � ��O:�Rӟ�C?��4C�,c�S�@�%�WB߲e��)Tk5޺�(�i���3�	�@U��G �c��C��/ݖU�g�܅{�Z�R��MT�����z��~jH��=ô-�K ��q��S{���n��i�]��c$� �|&��Lj|�W �z��@6�f��C�FU4��������\3U%��te�B��}����5�Kbe�>O�b�=L#�/�n0�C�b;!�=����Z�6L�l]8�8j5� B	Z.�b�j}�S�B�a֡�F�~9W7/�v}Sü4͞�G�~/!8��=�s{1��K���+{���Ғ�����������$0N�l�R�����X�cV[��C�*�<���7�ʝ��Y�o!-���e�sSB�=Q!q?������V��O�Z�'Vվ�5�mU�nh7E�W类M�Ճ��XT�<�p����j���o:���.���#�C�����ʬ;�q���7���u8b�F2��i�I>cW����?c�h���l�`�:'K�����߆�Y7�Ӵ���֝h��gW꟡�0�?e&�2p	���6�$k�N�d�E�UҠ��ݠ�-�UӀ�ׁ	�� �B̾��z�2(��I#t��<%^D�����!г@��)�6�Kx��H�	�/�A  ^=�]��+C�e�@��}ˈ�"�  _1�XR�k���O�g��"��,qy�:��z?��uȚ]�v�L��br"@cZjn�l�D]L$桸2+^2�cc��zVv���^Ŵ���b�� i��{v?����0�D7l�Ff�D�x����4��J�8?;7�]�B�����,A�Ŝ����Z�4C�������¨�R_��F���������C+��@Q���5� ��*-`��;�﫵����+�
|�C��e��O	���T�����w���#&��
�|��Lb�yO]�z@̈́r���K�9�DO4���!<8Tm�Z�B�~h��0,��� �����k��fw��t��p�ec����	���-�o*��'@��u��iv_828�ʂ��B.<���=����g��ő�֍��`���gҷ�nn�1� n�������߫�����F`k�6,��e�~�	�:���|��0[���}�'&2��[tB<�{]��H!����	�7C�	��'z%[�swXb��	e�W����x�����������a�����[���������z��o�=�@���SW�Όwj	4��h��<x+�444'Aʔk�M�4q�k@�6�q�H���T�*B9S���|��Q���]���3����)�7�1K�FY�<z���rF8;˕L!�l��r����A ����o�lY�.&���B�C|r�6��hP���>Q�x+���*�,ީ\�R��ճjF��\Ϡ-�f�"eխ��0�z�f�g�{B&���/���g��Sy��/�˗��R��?�L^���Hwci%�{ o�@z�[�f |���ݒ4n�e��A�:���u%�.���%0;��$�������4n~�'F�����M�z���N�`]����;�v���m��	����)�N��(;��1l�������_"�����eh����*��Qݮ����g� \�M��n	��+����q�,MrO�u�f��	(������L^[�ϼ���Er�㞰�1E׵��l
���X$2�����v�g#�N��Nf_��G m��v��6\~�g�ީ�1>�[O���j�j��0=�F�t�
Q���u��m�n��q��Ҫז4�J�׵��l
�[�����o�6����M�xm
�X#ˆ]�}�u��~���G\󅙜:�����䥈�f��9��y��a��m�ٖ��"ϼ�G~=EAi��V�:3������g�މ�7��R-�P4(�?�hf7����?�������gb�v�o#�N����rG~۬�u׷l��`?�#�����6�k!�i�O|pZP��Ʉ�Xs"�o�'���ʕ�?�dS�V˿��?�o�!,���Zĝ�n�{��ޣǕp�R
e�(��\A�rR��I�_���@E�[�E���'���ӡi��};�u���_I��*��c�w ��rT���p��N���P�������!��C�W1��:%���T?L�v)�PE%lK�
-����'rs��_:޾��������4�������P1�����E���&���'�k��ӏ��ɧ��ۿ���|6�����q���F�e��]��2��u���Ѱ�DÍ��JCVjlC�jQJ�ðe��x|��@���ӿ�~��߰���_����/�����~�o�7;����돉K�;����ϸ^OSgK;_����)r��;����*�n��S�ww�xg����:���/�񣝿�h�����3C!���[;��������ߟ��~zd�h�v�p��Q�g�\W����T�_���u�	�U���������{������y��u��'Ë���R��l�M8������/FHki���(�_�eñ���7��¯&τY��y�j��=�x�Sp�
�Y� ���ФSP.iXˇ�N(�,ϡ.f�]v�T _�����_h���{�j����<M/�AT�ƈWl���VA/�$�� �"ԃ]��ݬ?�a�r#�Fk�,���.e6�l#m(
l��X��e�Fw�z�Qk�F�H$e&*�Y�W���꠼ƻtk`h�.��U�T�Q�6��q����������Tdr�O��B�Y"�e��ҦK��ի�+�l���hĥļX�r(�O��C1�_��~s5Z�R�\"Q+�}*��Y��?+��$VӅ�>"�P�����;�c UY�&ԡ�Z~B�����WB��Zl��/�h|)��K�P|VW�=@=�l=�n����M�n�k�8ZT�L7��.��t��i����š:��ڬ�$ga��W�-��l	�y�����V������+}S��U���f�����l��/�]c�+v�Vڸ��Jgb>Q,d������H�l�Md�4����iK�����\����T&�r�̹�^Hs��PH\bz�&!��%d� � ]c�N.i:�`W�Q�z���u���i���,h��'�Q�����f�}){��E��/u�W�`$w�Ma��,�&�+�kǝ�� ���#�U'
B=^�P�z�9ˋգB9+!��/\7�C1�Bm+U�*z�&�*�sq_���	�
|�p ��O��5��x3�ݍG��>gݦ�^�cُ�\����~CvO3/u����ݒ�{��*W;1��Yz/�nD���坻Uӽ��_���u��(�1�-��HXq	�[�.6_y2`���vK�d�?;(���{���U�6"��R�!����� n��Ϛ͵h�|�7�2����;��m.�qc��)�e��M�[��´y���Tx��M@������S��;�1����z#���@��@�@��3c���a_����
���q|���r�`�����F��#p/��Y�����o6���'���w�-�����߷�gz�������o6����o��x����`S����_4�?_�����F ��S�<�r5��\UtK	)��mA��&�dx��)eK���PQ��Oٓl��R�.�7��N�P,�\�w���B�$qX*�D�����X�!�>^ʖ��%��.�;��G_r����?`���x:"N�ض|�o�.�S�W��-�T�Х
��T�VRC-��j�Kn���HL:�0�QR;3���(_=�Q��+�&eR����o�y��i�U�,9��X��%N��������ZR��Irn]Zt���Q�I���Z7�S��@*ǝ��8��O��ݫux$e��FN�h��:�0����8�s�&��i�M	\�$�Op%%Qjrb���Ԓ>^�k���W�٣A��00Y��g���>���g��c^uR�Ţу�c�H����i�r!6��;�� *�U)�9�&�L	��&y�yԔx	K���T�$�H	���JI�q^��NtD�tJ��qN�9I��6/����5�䏬�sV�Z�}�����q\6̂گ0䀕;���5��=2��YD#0Qv8��e�5�<kd�d������z�Wc�lJKұJ�O��ڮr^�Q��I�U�\*�(r�"lk�,u�;l'V*��|�'���#�;��|b�޷����]��������6������>�6�������za�w��o6�����������Lx��G���&`]�_I��F���+��^%�8Z�N[�z7z��s�LR5?Ss���#$����-I8<���W���fU��[���Eiz_>��6w��)��!�S��tQ��h'L|��r��QS����z�jՎy�¶k5�#�8�$'�R�RUq��H�f�}�Ჶ[�L�ڼC�u��,cx�.��r$�g���<U�"�\SD���������ʆ#�ItM5�L��j��,�z�d��4��J?'�$+U�Fb�:n�[Yn�Dt�=$��Qu7�X\�!
y�h5�RE����y[���E�\?���X�|�͝b�+���J|���s�l�|SL�%�/�He��q��r	�� 	��fI�A��qZ���l�8x�o�.
�zcx�Z�,��=#��r&����էf>�%�$���ϝ'L�8g;������vx��VU��_�ͅ3V��h�0⢐�PM4��Y��ZTA�5�s�4�0Q7�I��9���ҏe��>�(�[�����F`3�"o���	���Î���g�Ȣ�����Y�?��p�֬�
������S�����?n���|��嬗�;��Ys!�/Ĳ�Ž��q2J�PS:^�=ɶ�6ά;N�-�?{gҬ��m�~E͉x�o5H5$���T�щV��7������|$���"���{�޹��䶝�_+�cXJ-�_��hQcs߻9�����vϽ��`��}r�w��Ƒ�UҷL�^^^KT���v�x�Y���������l���?�x�nYUw��-�6�^z��������@�þJ�D�[�>�P smx�`�����rL7�5=do�3C��!���1B}�����\߫��=�Ȑ^ Cq���@#������񒍌�����}��w��7����y�2�aE]E��T]r��1�^��S�M�$�$T��w����F������P�5A��t:E�?������������-����2]��`��=�y����?�����rҗ�h9�����H�t&G�x*��u|��x���]�zW�(S�\o@'n����?����VΊT��z���c��~6-���/b������I����_��g�v���^p��� ���35�$=��|���n"~yd>��U�YYIz^]3�~Irk3K#��}i篇���Rf9�������F�?�yr��Fx���sVk��xN���?����P8��4A��ğ�(��&hJ��&��������o]��'�O���-��*�}�������߶�S�����]��,I��ǳ��)�!S&�	�Ͳ�Ȍ��8�#:�x���\��9A��MӈH����_��M��b����@��	���ͬ���_�~���CT(��:o���ѣ7h�E��gw�ޭ�i��b���K���n�;q��M�T�JZXh"!d����v?��ø�Vb���"���[�!�|�vB�@Quߪ�Y�M���-ԩ��in�:�ݺ��E������g�՛j��]X�I�z��8X�������[��?�����3p�G[tG�!������h�M ��������P��P�A0|ˀ����_'����?��3������L7�?���'��	�����?S�����x_i�Rj�\^���j��M�?�_���"�u���tP�D��E|`�=�*yQ�Oo��x�Հ����.���q>�qL$fX�i.�&ev+r��l�[�P�q��=�����h�q�ڗa)_#>�o2>;9_3>d�ӾϷ�Ʒ��DȐ�*����ʐt4�G���;��S�:WM���]�������t�z~��{m��g`Mi���Y��r�2�r�.�E�O�W�J)�vf(�����r��R�w3����|c�����l�/C�z�4�/q8�Xg`;Q�A�[k�\�A0|ˀ����_'�����m����]����?)�j����O�����V�h�u�����O"p�ݥ���g�?΁�o�.�?��ۣ��H2�r�ac2�b��,b��br�͓$ˉ�ˉ("c��@�q��4�E$���w�����7����+�sS��|���=l,�����@�Tq��c?�z��������sڛD̞^,��Z�7*��{���H��aI˱X
�B;蔶�t
��s�`շN4L�2���T���_Ep���ta�'������������Y�Z�t�� a�o������������Y��G����4�����?C��tA�����hJ�ݗ��W�>�,��?����?�F���?��?����?�GW�?����<�x!�2�!iĤ$����1Ad8�SG�O�i�$M3� <G0"�stA���������r�g���W.5�%�o%�	��k�.�87�^�[�gS}�e���CiV�q�[��|�!�۔��=՚VS-����,��JJ�� dܻ��e�)�\��<�.��.���kr�1�7�����҅��h������e�����k�N�?���A�����0$�M����2,��&��O����O������k����Z��Ǯ�:����������&�;�����������E&�gJO5ƖG��x �������u�{�d�����?\�<�������c�O�ӥO�vEK�hb�>��a8bC�\;��&'���'Sc�Ⰿ=᪑J]͋-��V�eݿ�A�ǡMȶ0�r�=�V�7��pKz=�7�r~��A�q�����Q�W�p��{�4���t$}>O�I���؄�~5�������h����Z��Ǯ�:��p�CktD����D�?���������?��!������c��?:���]�uB�!��5Z���h������?ڣ+�/�$���dY�$�T�B�D<A�I��$N�9�g$��<ARy�'1��� �?G��?��W�����g�ї���;���6c�L#<L���<�z��K��9�	��
Y�Hwޗ�t�TQ��紋1��Q#���S+Q�⽗\.�ʙdi��&��MW��i�mU��9�W���V���C�G{���C�G�ta�������h���?� ���|l�������������Z�� ��e����������� l�3]��4C��������G������#�d�o�͈��	�|����_؋q~�f�1�ߌ�/�����!�j�:�#�(GW�D��3�^^�}~��18^1鎴�;
��֞cXF�|~[#���пV�p�7�a�� }���RN��fm�E��T	9�_?�fY��\%�x%�|�u����'�Xu�!)����V�p�}�U����ˋaNd�@�|���`%N�q�V���_�&��4�{^ aC�����o�@\�I;�Xֽ[{,]���S�.I9�&��xsa���PQ-/S�a{.�����Ǯ�æk�i|��8��t/߸h��ӯ)��$�Z�C{�SJQ2���%y������lv=+2��a�G��ty�����V�t������}�U������w�apMߦˀKN������U���r-$���qi$3�Z����:�S��rp9�YR��~+_���s���b��L'�?��h���?��h������C�GktD����D�?������������������x�����i�����?As��8�����s�`{��4����������������MЌ��1����߶����/��n�����F 	���)����?�i���Ce1�n6V63\�����KMne�o����Wut���S���=q��/�󉤋�����70�����^x1�X��r�T������e��/�z�JYWw�ej����tM��9�g�O�m��-��G��ZUj��Pp�A){�\��{�k������u�ѧ_�)�;N�QToLG�w��TUԀ�ϘwBI#�W0o��d}�vn��lc*mM�o��⌞�X��b��l뿙.��?ڢ����u����������hZ���w�.��g�4��k�����/�S�j�"s�X����j:���ߣ����z�k�����=���.tǌR({K۽đ��s/�73��d%��'�M���:�Sr���yY��{9gU�]sgL�8���7��M�����U�sgl���pMb��O�51��%� ������'����"YT�R$��~7���!{,v/<-�7���rܯ��F���\���DŪ�e��J:���U�|��يƶ��u/И~���>��w��{��^��������u����������hV���w��[��������]��m�����p�]����g�?E��o�.�?�?��p�O#4������{ �
�?���O<9���в��q�w۟�G���m���'����F���D�yJ	��G$|��BN�dD���gx�SY�sB���FKf��8������^�zo���K����l�o�3k�!G����_�����N���u���fQ�W�{�ˋ�ď+i�������"b�`75f��᷅�&BV8]P�l.R���i��ʽ�|�ֆQ��g7g�r7�����40�󝀮��\�^�̓�]
�G�d�&���gw�՛j��]X�I�z��8X�������Z��?�����3������j����G�(�_@��?A��?A��-��2��?v��	�6���F��? ��;��Ͼ>�I��o�������������)��('_�z1��x���oz�3���?sCĿnQ��ꭓ��w����A�S$��95ҫ}�&3���bt���5�6]Pm<d�S¤�ٔ�<�	V>�}ՓNz6���b�dj�a޶v�b���'����NF��3���}�o�v��D%B�tT�ǟ2�͕!����xf��0���0ǣ�M֛�g�aMX���ʉ�����=���w*!�@��J#S"3A�y�Ϥ����*;u5���_��j�\�{Ģ2�GgM]��9{}u���g�̺wL��`��"������9��&:Q�A�Gk�\�A0Tˀ����_'�����m����]����(�@��?A��?���D���?���������.M|�?��	�tA������?��)��y&Ĺ�q)/pl�挐����ޕt��u��WԜ�>�7��C4�@H�I-� �,���΋��΋���YI�8������s��HF�S��p��(�f)����IC<�ӘM�r���t�����Z�'����U��}!Lgy�f�R�BG���K��lOC��i������j*Q�J���7����pH���UL��	��<���U尙P�~S���
n�H:�B���Yqv
��w���M���[���Op����ׂZ���#�������	
��: ���C�������ǜ���?��:^�ߩ�3���������9�����}�Xh������?�h�?�h����M�?�h��?<�Q��	C\*�|�0!���GTB4�Qsx�q&��	�r4O�1��P��G�?,�Ԃ?9�#Dg�����_u�d��uO�:�J?��|�0Mc�\2�!�/�?c��<9��,y,.�Ҏy�'�d/�
�0�-Û��Q���oR�i������u�)5�]˶w�]�N3��y+P8�a�Csh�������_s@�����?� ��!�&P��w����������O����O�� ������ϭ����h��?�l(��G�Y�������?��G�� ������ϭ������������� ���C�������#����+������H�?�4����?�?��������&䣀�ؔ�Ҕ��X�J�'�0�0 �(&� ��HÄ�m
������
����O��㍬τ��6O����c�;��q&�g�M����B8�^�?l�xF�Li
�ܦ��A�}'�R�c���ٚ�p�'K"��t����]f��ۣ�*�k�~8sG��$�!��@�������������_s@��!��1���0�`��s�?�����������k@�A�G� ��������� >(��a���4��:���������??v;C�.��K����B��o��鞍ɿ���Ko������<�ꩥ�B[��u�mO�v��4l&�y�Y�~�&��ԇ�L
�`�ѣN����Z��G�c�R�~�l��s}��՛�&{�<%��ٻM=���]�G����aN/�hW(�|ƒ-q!�ؘP8~Y䁞N6��d.�h9������Ө�{��mV����ڿ	H�?��h�?��h��?��C��!��1 ����
���������������K����d������~��s��|���c��o�?��׿|��*���x�9��׿����n�C���.y��������C����^dP��t�������0�U~U��*�,F�W�_7�ώ��`H_�c�<�����;��t��������L�0,e[��=V���Z)���/��z������#_�ao*M�:��������\�z��fv�B
,焗gb����V�+�;��H�]/���h���+{��|��⑞x�d���+o�Ŭ�ǽ�x��ÁH�~.eʹ��"�o_�V�U�g�^�q��e\1E�6v}'��*y ���3����l_.��rd�d�k������$z}�d�}�>�=���]�x$�%��"��MB-d��H�W��,��|2s���7�B��4��m\ӷ[�Ћ4K�]�����=Mm��Yo��%o��6��(迫ڻ����jA�?\�B��?��C��I�A��-������$�?w����\~��͛��w��Ov��l!㭣�,H����_���?������?��Y��!���z�?N�ycq�IY�2�ԓ��9�T}	PU��SvW�5?�y��)eM2r��'#5!0��/
c�O�xp��vVDc���;:�a�R�M�bFՂYQC+v��!�jv�����G�n�<�+��r1l)I�J}��{Q����/I֤+Vj�T_��F�0I�T⭲p�_���2+cwԲ�9m�L����~Ɨ�s$�S6w�_��Z>`lD����.���ٙ�g���:��%�
���{����h71�p�K����eKi�WF�7^3�ú;\��j�ӎ~oa������K����>���#������Ղ:���.��n���C��9���w���� ���3��$��:��/�7�o��u}c+����E����UՋ4w_n_��ܶ�:�����՗�V�����ū�~1��^�8����Ƿ�Oo���'������:3_gw�~��.g�4��m[�%#ܴ��)gE��JG���+��OG��j y�`�������b�p����զ�6���Ĳh�ϑ.6>�$_���p��r��7J��a���z92$�k��7�@����}�c��h����Ӣ�NO��^:r���l�I��m��u7cZ�W�\$ą*b�K:�0��:I}B��ڂ#&+k�V^:$ٞ9?E�V���������-�S�A�=�����������@��Y�����?kAS�Jh �����:��_�������:�+SU�U��i�݊�W���Z�a�xx�V�2Z���7���t���9�b�J*&򰥴�6�3g��xny��|r:$q����Ŋ�����n��&����M;�',W��;��Ｏ(�Aq|�a'5�[�H�݊����6�wu���=��_�y�Z�j�)�=>��N�M3�c.����n5���w���F�:�eC��o�N��̲����A�J"0�`?ڶ����@T����=�g���X���j���P��?9��W~U�s��?G��֡�j��e��]��F�?շ��=�Z����ϻ�ޠ��C��[�Z�+�ܱg#m�t��V]�g��F�Y]��95�g�N�U~jxo,hd)�64�Q�Gl{WG�����λ���;l�2���e���i�(�����rg��Ep����s�}�yݗ}2�vLaS֭����K_���c[��^�{rJ�Jv5��h�񡜄e�W)Ca�f��tW��$�I⭿E #��`��14����8P�0��>x��]���������O��-G��k/�c�%l��"�g��΢\ߴO�~=a�-ʒ��ۡ��.��(��%ՙ;jg\��k.;a���u��Ѳ	{6j[분��As~M'f�������=�����G���П�
��w�#5�ʃp���t�ÍXm����2��u�����З�(�W����{��[vK$s��������g��������
�����4]���?���9���� 迆�������(�x�o?������ �u 	��������/��n5lӟ< ���q�'���$�h����\6��� ���4�S��@��4�?�:�� J�$%b�dX�M	!e�$d>d#�Ho� ��`IAH#�b�8!c������ݿ(�?�w�O��W-x���=W��=P���?�+f���N���Up�ZV�+B{wv�V?T�)}�<�T�}F�[�t�ɡH�Z�y�ך��-�b��n���r���.�<��,�̤�6\��|KkYo8醋ޱ{��L������V?
v���9���yG��١?�ð;�֝������#��x�����_=�a1x�@�������n���j*����A]�����W����Ձ_���o�����^ �����C�w-hT��b����s�?$���۾�
�� ���
�:���g�����[~��o�?#��7/��g�g�/]�&�P�{����Ui_?���O�����S��Z�ݗ/�,Z�_P��E�:n+U�X�(�	6�|���^�լ1��9�&�FV�I/�9���pd������S?n+���sy�ۖ:�B�sH�tٙC+%�c2��Ɣ��EJ/�U%����[��lѯߚt���&�z��"�X��>�lU���e���?[񀉣�]S�cۭ�nRZ�ߗiQ�v���s��t.�n�C�$.D=w.C�o�41�NK�k����.=YF��֤�ڎZ�i�}� ��?C���7���[�!��ԃ����� ������n�#��� �a�#����?�����_���C���� 
�����?��Sj��u�0�x�߯�)��������?��ϫ�Q�$� �	�?Ղ:�� �F�y.bc�K��b�D�S�b!%#V ÐeS�'	���h<N8���(�p�D]��}�W�����2��&e[=�ǁ�.<l7�])$�>}��}w�{U��2���%������ߑ/���V�p�����������QF�����4~���������?A�GM�����=�D@����M�?�?���_���~G����M�?�30����$���I>�ٔ�h�b���1OKq��ǥ��G�\���:NN��C�
(����w��j����m�	'�ᒬ��Ʋ�O\���(�˽1�9��
��:E���q�$��2�P�X7�S�t����:�1���E��]ϻ��_��$u��h=>S�����l�=�3-=ǝ�`��;g&��
������/5������ 
�?����S�?a�� ��p?�A��������_-��p�����f�����5�)���h ����H�?����ﵠy���oM	��`���q��5 ����7������_	��?����jAS���� ��ϭ����������i���,�����o����?��?o�����6�}V�'K�I�(�.7�/������ػ�G����nv{k�7C�����]f��鶫l��&�r���KU����u�ˮ����Ѡ}�/� R���$ ���-�DHB��w�x@�S8�[��=��陞Q�g4m���T�����?�_,B��Gѭ��F��C^�ʽ���|m�o�����_���=�������;�[�����������w^�����;������s��\�qŶ����Wp<�TDY�b3(�c\B!�!A�����ě� �1�ah��D�r���7�=��2����׏ ����仿e�����ǿ��������x�y��x���@�Ł�aڮ���'������:�I�����T��🿽�;oA/z_�-�'o����I�^�9e��F��B�Pk�)G�t��߭�gpP��4&y���A:7&t8Vh�)t�0��/�Tz���!�)cU/�3�.�:�bJ �g����JyB�/�[q�ɖ��#TQ[u��2di���/c�>���z5�j�NsB7R�Un3%�w����ظ��X��'z��|i7ϩ�`�!�V��T\��9�ULZT�m[z���1�$��1�;�v��%�XHA����F�|,�9�4�
y��(Y��g-��u�4�1��V�hLa�+�t�(�-��N@k����	�K&ޝ]�UR�x\�	QT��J8׃��y�1���2����~�ǦqU�L-�s��;�5�&(2A�4aGs�xkB�p7�+�G�Ԑ�,��'���i�g�Nƌ��t\AG*���Y�`ځB\n:��P	!�4��P�4{dn@FK $��K�H�����Τj
�[g$���,CDg�0��dE�S�&�<�:���a�C�<̷N�u�����C��P�Z�WQpQ6�P�?.
j�U->�$�+D W�q���c͆�ə���C�k?X"��J"�r#Fw�b_&���]�k	-�;��P'���1E�(�.δ�I��D�4�X�m�%�OBy�MrB��y?CF�:C
�:�)ڹ�:q���.��D?��O���X�FP��N8�`Êg�5���%�"�ԅ��=΂,�d������d *��';L3���ͪ��J֡�H,iSO�Y�'�,�,9��/ƉV�Q��=�Κ�d��]�ϖ*�ZQ��`-R�]!��IS@��DU�h�h��,Y�e�A2�d�ܰ�
�7�Wc��1��e�]-*P�a�T!8C+�a�5�S��d��"(�6
��$wr�1��+;Ѩ?�O�L>D�t�M�SfO�Z9�KY��AI;[H�����aU)`x:���'Z1��K�:�����^�ҕ�T�L�5����ړ� ��s�u���9�:@��@g����vF��&�q����&�a�3Κ��6q��s̡���W�1��y����^SҒ�pX�R�� d19Q���J-�*�8m�Y�\#ա�7r/OjF�p:�l�I<��q1���\8}�9�~��U�1�V27Ul��:�*s�V�԰ft2Hբ�i�>��a��L�\�J�b�ʂ�/K�[M��5�6P�Jɀ!����G�٤�@#\W�RuU������T���l�h��L�դl`u���NT�Ԡ1HN��a!߀^�R����{/O���/ �R�Ul��_�a��mx~|~v�3{���.��e�������Ra~mY��!�܄�i�|����1-�<���o�}{w���s��ݓ�˕wv�����T�o��p@���I�l��C,7���7Q��=oʻ���~�h$��:_#Ӊu�U�<fP'�l4*MJ/F\^�zռš�H�uJ��+\_��%��d&T.�>��L����J��Y�M(�d����xs_V�M�����T��Ay�
��>R#��cͳ�{
(�g���=3ϱC�>��N��+uW��Hj��h�׵�v9%8F��J����jUU«����rŢ)�U�n2,���2a���KOb�N+5�uV.2e"R��2!5C=���g{��9���cA�?7�-!ڪ�],���5��(��a�_����d�*�="2@1J�Se�:���B�ņV�ܫ�&�����-�}��v�
����HN5XKb��z�<Lt�J����Z4�z4ĒC�r�Q�.�L�PMC��S!�Ws-+����V4\��d:���4T��59��X�,�&����t����P��6��J=5�Ů
��c@,v����7�m�0d-n�S�]��Tq����"��h�z�%F�ݾw���}���C����������P�{w࿾�Ω��\��l�O[����t���ۗ�KD�Y�B{I����a�C�Q�h�g4�����*E� �XMԯbd�rаX;�C�Nv���>�o��t�������?q	#դ�i���XuKz���܍�8�(�� ��L�R�T�Q�jv�xE��=hD�Y�#��O�mG��n2'>�:�L��nR��ű�xdq��b�H�z#�v��0��u땶)A�FQ1�VW� �+�d�mf�Bɱp8k-!�ԩ,A����L��s<����ϱ�sl��Z?��Z��୵�g�Z��n���{�q���z�F�~:�^i��X߇�����be|~}ղ�Zia�ܼ�4�n\gi��%���MVv\[�	�΂p�KЮ���l8}�[2|~z�15sI�^%Wls�D�߄_ہn}����w>�Y���S^�e���?�}�����;���ݝ=C�<c�f1>K�y�
�b8ށ� $�����.i>�>Oz��VM����G^o9T��[ �۪�"��	��:{6���w }azmJp�yε��۷����S�>�$�B���CH�-;�����{�;�P�Õ萣H x⃱��/a���ߧ5=F��,]1l���X0 >��7����O4r�����o(=���&�T�e���B��<�Q4��"�AI����1\	EQ,����D%L�X����6}�f����� ��k�(���o��~Z�	�d._���-�3y�'9w�ų�W~��t����!>�-{֣�����?������Hzf�o��g��mz>�?x���i�׎��] Hlz  ��We�B�\uv!�l��ь��:����W���G�� K��q�%�\���S��-��T#Tޅ¡b�"��Z+�9tOb�d��싃�m�yY�q����1�� �G�/���G���N�c�Q��{�jlr�K��^�r��±��#��t�w�[Ψ�Ow,Uy���c����������	��j����@�l�rM����빾�>�Ϫ�JK���uupuy��i���,oq��QJUTQp�.^��;6�4xl\7��ظn���9TWj ��fTñq���c㺡���uc���F6׍<6�>xll?xl<�%xl�>|��שmz:ic��D��\(�&� ��ior�K�?h$����o���"�-��Hz�K��j���ӆ�wz���i �j;."۶i�E�^�pA���!9��#�ȁ< U���Dܶ��}�ȋH�-��i�!*����>"J��
<e|@\�>W(�q���W��_�!�o#�P� �֑[A~���;��ԝ`͸o������+�p�����5F,�� �3'O��As�/s�vP�"h�Wһ��ȁu�z�hym�z�[W�?8K��{*5��,���n �n����݅�2�|��]H �����vӀ@H>wl��M�|wg�s7=P���9 =@|}[�!��e[�߯����Mǝ��}��)�W��P{^ɻ��Z�uB���\���W�
�=�_ƛ�S�@,�M	l��
_���ѴE��U���*}K��}Z���{R�~�6�AgϠx��x�c^��4�,���l�%�J���z�)�d�m"��)[�������-8HS��9�I�b�S�^���.�� = �k�!�>h��?p�_�Mݛ���a����/0��l��O?m>����m��t������cxd���I�������W$S�N�m��!ȁ�� ���p�k�ǣ[��U���/�CC3��k�e�	D��?ƶ�#������������W��q3䵾��A�WhM{�	��<�	����В��C,�v��t!<��h��㡃�!м��[m\�b�Yk��\�]Y��Q{
�>+���V�o"=���.µ��TL�צf�v����M��g츲�xb��к�.R7���֪��5Y0@+��@5f��<R���ح-�����O,s�����C�����j�!'�N�����_��cS��������G�������.�M0��@<�����8't��2m�9��-�;�5gjҹr�+�r��lT�4<_��Ҿr�04C�,�V����}������{���>4�7�3�נ��.ug%���Vs0/[�	N-@w�k�/���"M��	�bi�#�|��y:�O��JVa@O�b!����ut��������\��Z%WH&����]�s�(�,'��8M�#r&��Mߧ�����[�QoRΥ�F��6���x�M��S����ˁ�x����.�Q��,��c�uK��N�j�ZS��r�O�ڒ�6r "wM�-$��3�aJ 1�Ļ�,L�����7EG�e>k�}��*�0j�e �T���� ���n$=����|��M�B�������w��MQ�MjR�Ae2f�Jv��NR��J���B�H�@8��Xuc+M�R	�1�ԁ����u�����T$�;;���I����-�|��?�=����}����YD��R�q-����.��u/�Rz�����|�� ���.���&�*3�E>p@
��ڇ��w������u�������I+ֱ�X/�'|���_ѕ<�� pL��hִ�:�D�fU�%�n��3@z�?�󿺜'�����?�3'Φh����*�.�7�"
�C���/��9��څ��		"�H���(u�7��3tz��c,�w���G¼M�BX�T׼e;Y� �!�1�8�\R���:��0�1ƁM�D��5����?��؛���"�����[�����$K�ot�킕����h�t��b̍ё�ʡJ��|�o�d�7�QC�^ �d~��&�Q�x5Vq\A��~����hs��A��u�fŜ2�e�a�M7���4�`����*�B��5!	���LC4]�-r �OGׯR䕛;v߫��������x$�gL8!��U��h�̊��.IXj�0��R)h���9><�َ��{��Ui*�*�*.m:A�"i��Ro8,�j+i��Ͳ��Kpڭ�Ў��(�7�V��������:��0N�AV!�?�wF���8��\�z���cQ����lS�ʖ���&�Sv>�vɲ�l�ȩf6��󊦨f�0KzٔK9�,ت���B���pw�����zq�����?>n��L�>�ϸ�T�U*W����/����˶0�Y&!{�%d����/���8�l��0�b�����-�i�A�DIƮ�'��(I�x[�2,k&oK<6'��y�����¯�o����~��^j{����]��������3X��o�9�c���G��	��r��@@�Ϥ�|6�r�.�"�.���@�)�;�?��3�?��3�?��)��3�?��3�?��3�?��3�?��3�?��3�9(�Aq�s��q��:}L�U�l����=$�g�&�g�&�g�&�g�@ �@ ��gO�O � 