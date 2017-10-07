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

# pull and tage the correct image for the installer
docker pull hyperledger/composer-playground:0.13.3
docker tag hyperledger/composer-playground:0.13.3 hyperledger/composer-playground:latest


# Start all composer
docker-compose -p composer -f docker-compose-playground.yml up -d
# copy over pre-imported admin credentials
cd fabric-dev-servers/fabric-scripts/hlfv1/composer/creds
docker exec composer mkdir /home/composer/.composer-credentials
tar -cv * | docker exec -i composer tar x -C /home/composer/.composer-credentials

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
echo "Please use 'composer.sh' to re-start, and 'composer.sh stop' to shutdown all the Fabric and Composer docker images"

# Exit; this is required as the payload immediately follows.
exit 0
PAYLOAD:
� 45�Y �=�r�r�=��fRNR�TN�Oر���&9CIQ>���U�DJ�H�d�x��q8��B�R�T>�T����<�;�y�/�E�$zwM<H$��� ��L��b��̀��l�@G����C�����))��D�G�aa�?-I�=#b,&D���#A�E��# ���űlh��6aW���-{�+-]dZ6����3�����dms �L���3�f�P3����m��?e�6l��f��L�d����D��v�i[.J �ٖ�%l�?�X2����62�!P�pxPɔ?���|n��= ���D�@S��m�v���F6T�	�l�	_·rHߊd$��)�m��4@��u�v��ٴa�zTɤ5#���\v`�	�.�\��3�f��lH�ɠ����h� ް5�:������*�S����#	Y�tŠ��M�xԺ�"��C�bc������|1}�&���YԠn-���v�4Ga6Ud�[:��G���:e�av��P��D�����v\�
󧝖�|�X��+J}8Pê��V'��m̆X�.�U�-���ߴ������LE��9������a����裃,���?6��0�����ǉ�D�o�1�ɲs�eLŶ����5���3���f��ա�{�]��4�>�%����}n+����T�P�O�4t�4���G������D�DQ��G z��(_��7c�mD�(�3\���w���?:��p��4"�âD�Ÿ����U�'߅j��A��Y�1��ρ���f��|�Jʕ����r*�Vx?��&��tz*���cH�",_�Z�k,3���>��Ϫ�bx���(k������@�(xna�^h��?i����S�[�����7�ׅ�m �N�x!(�n����;�Vg:�6�sd��${�.�q���ӲA�1��̣�1�.�)k�� Ve"�\����O���f{�� �lhɓ�S�����3Jc�
����)�c7�9}��Z��隂�і��4Q �E��$�#UG�~~��˚���҄��oaݡjQF�{��A�+;��9tG��C��t5 M��u,�p��?z,���h��Qo�D���.��O�`"8<O`��ƥ�>���>"�=IL=�!-�� j��&���?Y�����]]�%�_�<�\�Â(H��e��� �偺c��|`7�Z��h��Dm�E��1�h�^
Y��Ȳq��&w�q�����*!б@��&���[�M�ă�n�<x���4�R��&��GqCB�:���?�ؐw.�Q`|2�\]#�Ó��8��\�e��!���5ۀ!�:�;������{Kfh�"(�sAؘ������医�1�Q��vd�=��vu~�� ��<7�Ή�̲�TF��q����  ��$z����z������O(���pǊ�a�=t���h6kDyW1�ط�d�\���u-,�#����4f������y΄|�`#�u�ޘ���y���:m��?���+�F��|�`���i�L�^P3l�z5����C��z��C���#*�����_j�a�� ���-�?��E����������2C�GsyO4��(����/��WS\?)=:�q�3�l���OO�v��;fb�稷�3a�u�ӤȪA�l��t���	�	W��W>TR��au�g�6!�����yveog������e�9ˁK��f�d9��p�)W������9� @��cX�~I�t�iSn�����k`���U�!�B�q�t+����#�,ݩ\�R����|!spT����,��(xn!2Y��y��wĨ���h�ٟ�
���OYTa�;��-x:��Ο�S��%a��\V�A���N��L��}�sK�H��1Y���� �����8�,�O��'���r�،�_!;wr^D�]������_��)k���.3�д�s�L�#�0���#����ܿ�sO>��{bt�@3Ȅ�::&�k`h�	b�Aϲ�W�;��?�/ݝ�2���?�����\AY>�l�s')����7���_I����%(x����L�$[���������ك���ib�%蘚a{/D�mh�V��;� �Rk�l������O��8������af?��y�)Q𓏉�Jӱ��?����Kz�E�X}�Fm@������D��O�_�U��V,ԧj��X��3a�F��E���;M+P�AR6➘m0�������[u�b�pO]�)�э��c�Xt��U&^+����S��j�w&p����f���#h�]��B������e�?.M��D"��[��_���
�HW�����"bÆ��B>:#*��=p׵ 7����@=������A!(.�Wୠdto����{+�Q�jm��������%(`��G�ؔ������������8�,���5�6��L��a������C3?�8�`W����BK�c��/�#��ߕ��������n�"۝Y���!w� � i�0���aփ� \�E���<��ҙ� P Bpn#��$ �,`�5�um��B��m�#�d��7��vы��K3�-ef��+��e�`��&�l7Ɉ��K��N�1�F�_�Ʉ>K3qx	$fdؘJ43s���d�cL4˅1�թD2O�v
���2���˕2�g���8"^�̬�KCMhS�O"U��dލ-�j�P��/7����h���_������*ʭ�����SоXF�N����B4>}��J��ϕ����>p������?�������?Lٟ~B���HR8�UWDE��^�K�V"��a)�H���DDR���&b-�׶�э�������4�y�_���;]#�qD6��o����m�ѷO9.����7�y㟸����__m��I$���7_���<�{����������w���?�.���ߜ�d�jZ�xL��֯�)#m0�Ua~��ߌ��=�n���3�V4n��G�������率�	�%����K�u��Ք+o�5�@�n54���;�aRz��%�d��A7�O�^Om:Y�o_�֠�ly���D%k��juA�oE���V����$�p��m�PP"��@q+51aJR4NHh>�+^AdY�S+@��%��� �)W��|J�fX�;��ϧr穔��r/����\t��⋾J���M\Ù�^���=|��<2��\f�	���ţL�YH.2�r9�(T�T�ج��v-�ځ'���|�>S��c�LK��J;뜆�����E�*�q!p5�K��.3�ٛf��&i�U�絰p����S�f���;c�=���T����+��Åj^8���'���	úw��y�V(Y�T�4}\*�2���G��j��]*Y�+��<9�*�h級9)$Kn�/
�w�Q8��3g�ӓ�9|S<�]fꅤ� �^�tR��IT&ca*Q岶������n��<##�,����JAJȍL.��>�2�����9gk�"Ys��J�p������t��<j��dN����]c�ur��G�S�'�e�ZѴh!~?���[�J<o��r�L��s���y���/��­��e��^���n#-�X�I�����e���h��|��*���|�m�A'��'�������?v�D����R�XA���)w
2�{Ff0%��9J�K)��+���L�c�z��-x���$BM��E<����qr�;NtSj��oT�{1�.��8�3���
��Syg�9.�BA매D������;��|�����`0��������׌��1c�?��S������(Ƅ�#��@�L���obl/�[��WZ>���u���>���벢�_���L����bt���2�'����8���)�}��]b��E6:�z��P�RC�����B	�U�=���c�"�A�܉�w�l)�归v���J�r�즬�Q��)�.�0qy,�S:~QC�ǜt�:���~4�����n8�5R��c�zFa�ȡ����O�V�F�BR�9��]����_N�e�������*�g��N�sw}]�2�x��_��\I��G��|j��g[�L�t�;�H�%�($-��t�!g`�gf��#X;.\�4��%�׍<lGs� {�-�2Hq�go��l9��X��qoo�uivې{⾥�.��n�hT�0-7vv��4g�{�~;���߱1,�k�`��W��z�wTZ�\MyR��7Y\d>Y ��NȺʴ�e��BrOh��a�M`�M{p�r�2��(�-�#���+�F ���Fu��X��Ө.hh��@�mh��~�E-����}�4��i��EN�y w ُ��( ��m��`,����7m���t��f�����(��q�� ѥFG6c	�������v�e�������7�b�� "<���!>��2�#ɝ|h�}0�G��q�v�e:�3�"�t�� ����M�jL�hd"g}�>�P;&��  �Z�G/0���r)�*PEd���^���b��n��� �4a����/�ԐEpg���)mK�,P��1���ۓ)��y}t4����&�~��u���4,/�+����3l�����-P�d�P�6���ф��b�󘚊���#�,�m�H���]�;;�$��[X�����A�|s%y0�"�r���B��m��`��m�����^������G�%0�ա��Ez?�`�=��N�~cR���I���'5sb~ݮ��8��)tt� '��I�}0dK�"�"kf&K5hΩ�|��e������F��'��F��[JإH�C�-F�"�����	�u x]Kt�[��Bn������J�O
;��bw�b��#��\���(������K�j7�W�2_*� �+�����릯��}B�.M��(�������o'T���f�k#�v�.�t`hR�c;t@Ȣ��E����~�F������[��L֔:l4LԠ��ޱu��&�ɊN�V!C���i>>Ƽ�u]�?�a=��T'�8�N۶����n:�� �W�T��n�,��`@>��4b���NG�-�P��1�NH(�� *
}f��CUe��
��y �Xw�&h�&���� �
�1YHc��_�"���w-��ci���i.HM?(�!T3ݨ/U~$v�˔�v�$΍�t�,���I�8�;q�*iZi@�A�f;$f�����A,X �X���#�㾫ruN�o�k���_��;��������KB?
��_R?�����?���ۓ����ݟ+�������ⷿ��_��#����pd�����^��я!V�mp���P�O?S�hHV$L
��Q���#M9�����&���V� 2*�A��h��C�/$�<
|�k���_�y�S?�~�+?��O�f��G��g�=�.�,���#o�P�z��|��] �����{�w�{����	�|���|����O;���߽yh7\h�@�)-V`��\7-Z:�RH�W6�>e:��n���
,�c� ]��^傫��!0-�pW(�FUq-���� �	n���H+	�g�4!��s�W �^C��-�g�"��y|I�mZ]���(����s昭W��� �h��P��	�Kq&.ZCw��t�9Ȏ[Dv&�fN�9c��5�*�z7���N��h����"�<۫����qP��N�6������4�`r漋fP�k��)����)�4�]�̎5]S:�K���q��t��DvV��͙�,�)+#ٕ�m!��,�f�Ӆ����w���B�Xښ��'&��Mք�E;s٤�lI�!���N����<�s�apS�>��H#M��Q����h������<��Qd�V�E������{S���` �XT#��j�LM�;�p\�[l}y��v�|����$%ͪ��Q���(=7)177��S~��Rhъ^BWg�[����䦻`/��B/��"/��/���.���.���.���.��b.��B.��".�]��K�yy�����[�'I���JF)�@�{j���D�czK��f�V��j�������P���%t�]T
���Ut��TO�LY @�p��L�N� ���u��<5b�d$=�"s���!C�4�b��[h�?�USD_nʄN�4��#�Z�p�,�ES�c��'Fcs$��u��A\�s�i���q���1	����lY��N�$��4�VD�)3�-�������c9�r����0�!͜ΔY31�W;1uA��t'�q��e"�ղ�>�p��iE�ʍrn��#2�f�v�ݎfQj�]�eޅ-Ի����/�� px�������no9֟W [��~	����Jx7�>Cދ۷��`�om�#Mm-��9�Z�����P'�|�A��.z���qGV_��x���E���-|���������7��1���a����{����,��D�,�t>oDg9QW�<S]d�H�F��֖Η���,]ru~�������˙$`y(���X͂�<]Ʌ��j�K.�]��8��46%pM`ʮ���P`�TEZd:-GY��Jqc<f!��T�Y�TdJũ�1;�+�^�Q�puv*�x67��f=u��|C=��(:>h*-}�4�y#L��vuY$���+#<j"5���R&
u<T�RݕH���&өs�w���~{�i LS��� �������-*C��.�����q$bH�ѹ%����(��U�����)��(;��2��jMY��d�����c�R�����eAt0���A�l���͜6�����.3T�aM9n̆�*�K��/h%t��#��e���ߺ�i��Pnz�r��Fy�<(�L��frzg�-.������������lȉ%]qdv�����	�X�	l}��q�,�_d��������3���2.�#��w��h����=��K��UmZH^O�#�-�2Z�dCW���1�HZ>�'�I]�f+�0��l=�W�By�T��>F�bF1fqЈ�������aT���h#KS��y6+p���mچ2g�q���S�YzL�`�#�S�r�)��|'���:Z{z�v�O�=��� S>�+�x2-l��Ua��wiA���jѼ�lT�t����K�"�4ڼ9�������0VG��d�O�<�ۭ��4�R�����b�@���e�ٍl⿼�'�"P$��"��Aa<�����ǘ�ܕBUb6��*����E2O������FH�P� �=�q�	���/U&��s�I��BA�{ޫJ)=ʕ�i||�SZ)�!y�T��؄Kb�1��v�����!��8�%����Y�d����ryT�&C�2:��Htٝ �r[���e�B��3u�<t�·KSR�>4��M��B�[��Ka!%nH^O�0D7����	��Bs>�I�R�"]���yz6@�A*��tl�0��J�Y�ױ�4h�C͍�kp(�b�Ѫ�J9V�q�1�g��Vv��eـ�|v黁w���W�����	�L�k�l�_B:�hQэ�j��2��4W�S]\�����[ț�HyY#?�HF�[R�J���Gȃ�ϟ�>��|y�mGI�wo"o+��"_g�7������C�.^ ��M�J��<}�<HI:YKk��UQw L{���8� ?��J��(�O��	������׽�<��YZ�'��+z�<B>t�O�O�Уׅ{�{��#�5��C�K���?�'2�׃��t��?�
m������}�������`����z���I�U�m��\C��^�t�h*Az���]+3�o=�t�����X�Hŀ�bGn�qH�@�Fh�E���~�/z~���?��_��.nw� ��|�$���Q�Z��]�^6����i�����u������*�h�k�rzU�*�dG'Nv��e��15������/��K6$�d���~$�(r�����Òt� 䣍�"X�E�jY� =�]�}��1�..��;ol�0hY���`]��8�N�A����T��C��Y`P ��ԧB�|5��+ ����Zb�FV�&�'��w��GA�~��=�/�3� "+hљ^�|�l���ֺO;Ի�ƫg�d4�{e����s��x�.��
f��VTϳ^V&֟�:q��P4��?ƒ�u��8�ֽF�hǫ̮�$�viy=_�6с>�w�2`:�X`j����x�[	`�'갥�%�$XY5
��pEd����\N _n���3r�ď��Y�D�^�A]ןw�i��&��������jm��]�
]���g	?ϯj�H&#]���;�/�����o���t��=���ި�5�w oAxs��'�s(sc�6A|G�m�7N~���'���8\\�s��5�+u��3�`@!�6[r8?h��C]���&���	��ֹ�5Q4�l]\/G�ؖ�'�=��(
�q.�0N�� �� .���e�b�g��ٗ1��6�18�x1���R�/ٰS�	���n��r�8�I𢍷�]x�t�1��J��B�z�iJ*�p���m�B�`�����BN���^;8Hv��o��V�a�(X�Hp�W��:�4�4
vY?fv ���t���ڱ2XC�Y_�p��Nm.�F7�y�Z�4�,k���r�o�������i��"�ze�J�5,y��UǞ�D�ӄղ�p,����[6�7�^���i��e�M�[o�R��w[��h�����ZL�o���n��V��v5!$NO�9|r�k����@=X�T�5�l�/ �C`���qe��*��D�ࡃ|�F���u��mkCL�D�)�İ����y�i�vq�/��������4T�ܻ����886�P1�Ѥ�ȍuK���5��c�Q�Oq�G�w���w�_�b��z����ύ���C�\��������E����>Xq���  �e[%;bnزS;�F@4�ٷ�YݳN�L�����3��-tguM�(X��~��V;:�|tY)��,�g���j׺^��p��X���S�~�v$���v����$5�H�P$2���6E�[-��ˑ6.ID3d�#�f�َQR8U$�����-Ȁ��]n"��aV�3'��e�v�OZ�O6�c[��'֓�`�0fȵG�cA�	���+��U�Ǥ&EJ�fG��,�8��[��$���1%�E����2!!����ƔpD�%JR��	>i��N�ϱ|"gcf�m�7]O��[zr��8K��';�����b+�}���;2^���b^ȶ�"�-�NrY�Hg�2�d��p�g�Ҝv.�ƗD.K�l�+��aк�.��-�%�S9�<�"�n�rO�/��vɠ�tF(�y���x�� ��V��=��*�
��ٙNg���@;#p����Q��	ii{�֙�uP�������7� l����ԝ��l7<�s�D�;�L�v��3d����d7�_r�r1�oE�����"�<�g�gy�+n:|O�|6�cW9m�`9��\�Zθ,���Y��t��OP��љ4A'ӡc[=���	K���,����ȟ��f-m����O���\I��	>y���j�x*X�{�љ���z�k�cHng��ڵ�i1��3�����c�VْH�����E��Kܳ8y�2������8cr�r'ȍ�JƢ�ʠ��O��'O�كw&��%MW.`a|}�@�1t�"����d�������|�l�Ml�9c�o�.�c�[��W�vY+CY?[}�y��sH#�:vkk'���fWH�+�oE�;�˜������y�:P�Q���Ͷ�w��v�80`�w��/a���#�q��ytG7^��e����Gz��%�o��!"�����M��������}��������ۄ=�=�}��-�?:����WA�8�)��H� ����%��ϋ?	��4|eӾ��%�qr��/����{I444/��}���+a��;�쿽�}����]`[��X;�qKv�qLn�CdK��V,�[
Ţ�P+DFB�H8�41Y�Ä�:�_u~�ӫ��Q���w������6�d�8���>��CC��2:M�#��}������t��뺒�Wf��F�T���S�"���6����a9�Ck ��"Z���^oKE�I���Տ�NJ�zoҩ']-����2�I�0��{q���_���WA����/�|�ocC�{���;�c�os��S���}�WA�؎���A��#�K�_������A��������?29��}�{�� �}�S�N����.���������Kz�?���@�S�����?��{��$�-�����Gz��?�#��%���/��3LP[����#Bu�{W֝(�u���k���Ż�Ǥ"�"��ͻ�D�@QQ~��I��v'�� ]9�*e��Rt��>���ꄣ:��#�?�Z�?���'����?߅�2@����_-����� �/	5��� u��)�~����R�V�o\��p�m�S�z�9�ڍ���uB*[عp��YT���kBr���������~^C��������'���<o?��*!��c{���Odi�=$v��J�v��:�m��^3�j�[�i��X���-��l��V�k�����C�E��Ml���Ц/�H�ݷ�>ok�ȏ�}���j�dr�������v�8]*�'$}4�Ir�M7��<ݒ��)�w���^셩+G�9q�*qϦw�(%�,�i�����'+ߦh�86���ooX��z��?�;UICKF��Ǝ2���������5�O�`T�������C��2ԋ�!%�lԢ������ߥ � �	� ��������A����,�`��*@����_-�����W�����@����7A����C��������R�{���[�|��g4���*�vb����V�����u�KY�;��Y���G���;e���O��
ǳ��Ң��7�õb"�K�X�]ZqR._3j#'{��D9&��n��1=#�Sa票o�7CZ�59{*둿��!���S]/?�����sI�D#W�/m|���o߼�����y���N�#*���q�]��&��p3�/�)�tBЛmm�&�}�D����5IA��+&:ܨ���:N<;����Z�����+j�����Wj����9�'���
 ����u���{�)�����N��<��g�(�Ky$K��y!��1���>A.��8��(��>Ep���(����?�����������9��ɠ�j�4�%{��)]�\�8�EK�l#�-���,��#9�=y~Q'��YL������얓��8��d�����)�"9�$�7@�0	��QQ{�O�t �������?�C����
��������C-��*C�����q)�~1� ���P�U�_Y�tC���8n�����h>�h{����f�8�2�,9��?�G�}y$F�f̸�9��\�w�.Q4��,7c_O�.#te�~L${d6Ϋ\����s:���ؐyT%���PP��������V���}��;����a�����������?����@V�Z�?�����������"�{�� "�m�w��z��N&��iz��,*��/������3䢶�?s ���O���Y�><�"U��h�/��J��� �q�%��V�f��O�H6�]:�2h����͕^k�0Mi�oD�p�c�	/�һ�'��S�9�f���߬���H���8zy
ל���+^� 0얐k¥�	��.���80���|�E�PoG��X��uC�X#�²��O��L'm5���y�0��[a�L����ED�<��I>�Ɇ��#Uw���d�C����t�v�8��$��Az�ݎ�4[�{|,,B��I�:�ͯ��D���V�ytt�9>/������^4��������W>���0�Q_�q�������C��G���������R�2�j�����������|@�?��C�?��W�����E(E�a��є�yJ�(��������4Mr!��4�\O�p	X.$�si7���OC��G�(�J����u��aY(�MM�s��*��шO���s};"Z��Ġ�_s(y�4�g�,ȅ�l������ȇ�fM�4^�I���_��#�mr%8�:�m�\o�9�iY�>J�[0��^���������|>�_#�~���C���?M`����Z�?}����_I(���`C�{��_5�_�:��U�����~���	����'h����������/~�����Ho����>'&N��ʸ����J�%޽�˸>G~f����3���V6��y>6�ý;��ǝj�Aޜ�nX�$X{y2-m��>���xA�ii���VW�lz��Y���Uy��fS�0N�K�n2J��!����²��Ɠm��˕��ޯ׶I���;�=0�"p�n�[��z����W�~��-Z��.�!]�p?��l��!��jЈ(G[Ϛ�$�5���`$�
����G�Q����J'k�{�V"�����Ld2�:��"�1�@��|�ǲKC��E��������P�m�W��1�_+B����uC����4�� �a��a�����>O��WX ���_[�Ձ���_J���/��jQ�?��%H��� ��B�/��B�o�����(�2����Cv��U?O�c�q�?R��P���:�?����?�_����c�p[�������?��]*���������?�`��)��C8D� ���������G)��C8D�(��4�����R ��� �����B-�v����GI����͐
�������n���$Ԉ�a-�ԡ���@B�C)��������?迊��CT�������C��2ԋ�!�lԢ���@B�C)����������� ���@�eq��U�����j����?��^
j��0�_:�P���u�������u	�S�����?�_���[��l��B(�+ ��_[�Ձ��W�8��<ԉ�1�"=4dho��K���Oz�ϑ8^H�f�	�]�e\����\����e���}Q�'h�����0TF�
�?�<����Υ�����h�^�ÈPT�{=AM�&/=q��5�I��ǫ�qՒB���?̇�.��pw3�և�f/��+2�bD��U���!GK�l�3�Z��=���8�㍝$������M�>�{R�B�u(h�D��vwO���f����?�C����
��������C-��*C�����q)�~1� ���P�U�_Y�|B�N�}��[���"�Fo��� (��˿la���̧��}���p�7�J/�d�a��\	��A2f�9���U����ZʶiO�����4=���`�I�>���0G	U9H��b0�)����������-	5������w|m�����U����/����/�@�U��������#�����-����k�B7�X��sbd�#+DF��V���߳��J;Ip�����Dޓ�G�={�L-�ِ�KnK�fg�z��H$���8V:Y�M���{јF�9V�a�.�_{n;#2]?ǽ�Nɂ�-Wϴv�#��n���׌��K'^���%�py/�Hn	����5��e�>��fB�}	��b�~��b),��>a�3����~Y��5��s��-'i�3�y��G�l����q��O��33���-��e8	l���D��h��7�Ǔ(�L�Fx���l�R�����+����p����w�x�ep����ϸ������O\�׿ԡ�������]
>�����#^�E�����D1��ԁ�q������e�����L���,������G�8�_x���-Q����M?��t3����qB/���vׁ�=�W��$޼����fi���7��n����s?�v�d�!=��f�!�=?#����o�m]��ݬ��պ�:����ϱ%c����qZ��	B~�3�°G�*���^�P�j�����F��,f�l��G�0�����b��̩ޤ�}��m'�y�X��#l1�%�O,��ܢe���'�͝�ڹ��eͅh*_��%~p����o�.��&>�')2bA�7��DC0��"wCl�mr#���j,B��K;d�Z�z�2Gz����|ދMV�"�K��Q�h�;?�p�\#�
�B,1�	��t��<Mу��rM�O{�@�)����8��3�Ҫ/����������KB9���(ԣ1��������s/����PGqz6���f.�x�O�h�q��>�f�g������E���_)��������?(��[y(";�n:�[wq�'�P�,������˕?��#r�V`����������@���H���@������RP����������G���Ѡ�J�[�_����w�OٳǾ���@�u�N�`����U���筗�:9�������|��[~�C~���Z�;���&�7���n��>�� ��1�ku�-�݆����@8z@��j��1��Fo�i�kt���ܧyq�~�����!�����ɺՍb%펮��Q��f�!|?ד�u,��(��Y�!��w�ɖW��Y���d>���U���Ǔ�L�f���z��V8a��)Q"��F�^ڹ�����y�U�f�4Úsa��U�p���XYtɦ�h+��;+�|���~7�A���`���p��\�'��fY%f,�_;~>}��b�p�y����ˢ���/� `1
wq��<����'���������������_�C��6j-��r��i�R'r��P)��2o�h���/���˖�jA>*[��{/>�������(�e������
�����w���p�c-��_5�C�Wu(���c �T������A����������޷��i��(��������Yt����_��`k�r��>��U�۹��Z��B�o"��H�Lh���/�.-��*�<�<?&}{,-�ޭs�|�uu�\!OGW.���O�����IMl���WpsR��-O7y詓[��ﷷn� �Pԩ��/��I':��L�����J�na߽��k�]�V�x��ʯ+ᅽ��pR���<
�q��mm�y��S9�Z�Y��}��@Vc�;��񩶪0��{0�Y�����iۮ�ܒ#-WĬ%p���jV�+%�L�)�������� č��R����	�xsh����0�]�������b۰%�i�-��Ȗd�yQ�����UBS�5�I�cʳ���ǫ�p�W�>�W1�h)�F�Κ�����`WLI���J�;J�,�=�Q�_^P+��Hz uY���~���<�Ե��!�'��������m�y�X�	Y�?��\����|�3�?!��?!�����{���1� r	���m��A�a��?�����/�%���� �ߠ����oP�쿷��ϫ��J�����~��!��φ\�?Q��fD6��=BN ��G��W�a�7P�:.�������OS���SF���������\Y���ς��?ԅ@DV��}��?d���P��vɅ�G^����L@i�ARz���m�/�_��� �����t��������?���� ������������.z���m�/����ȉ�C]D��������?��g���P��?����R��2��:6��#��۶�r��̕���	���GE.���G��C�?���.���H����[��0��t����_��H]����CF�B���(��K��Ռ2C��\�ʴ��6��%�4��IgX�^֒-,c�e�/r$�~�����Ƀ��K��������)��-����/��*4Ŧ,�r�ɔ��eIzzW�L�Z:6���wژܩ[$+�q M����4��7h��UhGl�#;ړ����	�t���Z�M��@���3[;�j��Z�9WrOp=M�kVo���V�8��[�����d�F{P^�_u>�{���sF����T���Y�<����?t�A�!�(��������n�<�?��������MZ��zzLLD��F!.f0�[����%~Ֆ;{����Ѫ=o���n^���6j2ذ���G�u�T�ow|�^4�m��UM���c$��ۥ:v�9���x�B�T�I����|��E�E������glԿ�����/d@��A��������DH.�?�����`�e�7��=����_�eGA�mO�Y��#W�>o�t�_m����ϧXk�L�|}%~e���۰��m�b�덻,I���,:���7��Ѽ���_�ø0��qaˇ�5�N�/'&�W�l:R����Z��E���*��q:l���+�)0g���~�5̫�G[�?���&;�jM���4�x*��a=��+£-88'(qb����ͪZ��6�K�{a�)��W��@	�S��.Eue���[eZc��`a6��T���0-EU	Sj�c!�@H���:�fi���˻��mC&�v��	��Oo�$��B�'T�u���{�,��o���W�?�"�dA.�����Ń�gAf����e�?�����Z�i���gy�?�����n����O]����L@��/G���?�?r�g��@�o&�I��
d�d���[�1�� �����P��?�.����+�`�er�V�D
���m��B�a�d�F�a�G$����.�)��Ȅo�����s�����A�q|lU�ބ�[�E��6�6�Èkݧ���}��H+�?���z��H?�3�i�����IS>�����~��7����v�Nԯw�U��;N��B�e+sf�o����ސ�>��ٙ9���	�F7�З��0c��d�O�MM��WGi�/�G�~��~�+y��^=mQ lGZrAx>�do+(��X����b,(��Ih`��~gbW���S��p�Q�����jҖ��M�:�7�al`��M���ɰ[�(b!��Y����}+K�!����Q���0ȅ����@n��Xu[�"��߶�����d�I�_�(@�����R�����L��_P��A�/��?�?�@n�}^uS�$��߶���gI�D�H��� oM.���GƷ��J%��Q�Qݎ�F}	ǕK#�e���O5�_�������Dkolzkc3:>�)�^ ��˧��>����c�t܆F/%���{�:���~SѦ-z���b�	L��^���i�[4��A�C������7�e�|q����I & K� ~/�qOP�qc]X���Хa_���)s��ͷ�(��ZX޻�=Yֻ�"�ayӒ�C����
{M�,b���s\A�&T����w��0����+�@��L@n�}ZuK�&��߶���/RW�?A�� ?�ϔ�Њ�eq���K�9/�:m���1:��M����R�Ej<iY�a�<g�K<=縏�[ݿ?3y��k�B�6���?���;�[��3�?a#�<��F-G�~8��ڪ���Ө\x^��X8z�h���Z5��"���Z�1y�*�·������*w*9tayv��9���|\'f�jY��%�C.����|-y����':����"P����C��:r��������`��n��$��:~���w��bY�;�*s�+F/Ŗ�o=D�ݝ�;Qw���q}��n��-��~�i<�\fMH1������;!�#^��b~l��]�!�U3j˺��<�#:k/�xZ��������|���_,�@����C�����/��B�A��A������r�l@4���c�"�����7N�?[�l�=,����E�r9��[ҽ����O9 ?���c9 ��B /s 
+;�i�*m5�[��/�V����NӍբf��-*1��؊(�Y���ן�Ŧ�V�ub���ᇪ^�J�Bk��KI\��4���5!�w��<��Z�F<��.��`(�aM�����ص������	{��K%ٍ��Z�*�Nȶ��p"p����d���7�D)9O$7�j6Q׆�~iHO���m���"�U�@��"Q��4���͖/?�O��]r*=�k{vlYˋ��x��5��(GnO���ƈVz�>�����Q�i����߭�/�<}�����u}�7��d�����tw��8w����?3�"�{��?�����M���"�&�=E�(��aP��3�`���Cz�;?�,gm��ӝ�>�
r�1��w�.�w����~���������t��QZh�k��%fr�O^�8�1�c���J����|>�o�k���)�j�[����}�7��(��*����4�����o�E�K�Z�����Ճឋ[NF�^�O�7µ�:}b6�;�Ќ�;s���bF��lN#'}�LL�I��ٹ�&����#ˁ����č]����N���G���>�{�ܘ��d��߽�E������'U����_�������q?�'���b�o�%9���>=����ߧ���DER8o�����/��?n���b�f��w���c-iW����7��9�� ??Nx��OW���Zrx�:7}�ǋD����:���y>}�ĝ0ܙ������ǁҬ����^kA�I�n����`������\��W,\����[��;��K|���5'�`�o�y�6��������q>ĝ�_�O�d"�_s�܄��s��=�5�OOV���N)i�q��U�%7���U?v����f�#�[5E~��.N"M`؅�h��.����޽�a�����__�S7��������M�Q                           �%���. � 